import os
import sqlite3
from fastapi import FastAPI, HTTPException, Request, Form
from pydantic import BaseModel
import openai
from langchain.prompts import PromptTemplate
from dotenv import load_dotenv
from typing import List
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware

# OpenAI 예외 처리 클래스
from openai import OpenAIError

# 환경 변수 로드
load_dotenv()

# FastAPI 앱 생성
app = FastAPI()

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용 (개발 중에만 사용)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Jinja2 템플릿 설정
templates = Jinja2Templates(directory="templates")

# OpenAI API 키를 환경 변수에서 가져오기
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

if not OPENAI_API_KEY:
    raise ValueError("OpenAI API Key is not set. Please set it in the .env file.")

# OpenAI 클라이언트 초기화
openai.api_key = OPENAI_API_KEY

# SQLite 데이터베이스 연결 설정
def get_db_connection():
    try:
        conn = sqlite3.connect('chat_history.db', check_same_thread=False)
        return conn
    except sqlite3.Error as e:
        raise HTTPException(status_code=500, detail=f"Database connection error: {str(e)}")

# 채팅 기록을 저장할 테이블 생성
def initialize_db():
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute('''CREATE TABLE IF NOT EXISTS chat_history
                          (id INTEGER PRIMARY KEY AUTOINCREMENT,
                           role TEXT,
                           content TEXT)''')
        conn.commit()


initialize_db()  # 서버 시작 시 데이터베이스 초기화

# 프롬프트 템플릿 정의
input_prompt_template = """당신은 AI Assistant입니다. 사용자가 입력한 텍스트에 대한 질문을 생성해야 합니다. 

입력 텍스트:
{input_text}

위의 텍스트에 대해 3개의 관련 질문을 생성하세요. 질문은 구체적이고, 사용자가 생각을 더 깊게 할 수 있는 질문이어야 합니다.

생성된 질문:
"""

chat_prompt_template = """당신은 AI 자서전 작성을 돕는 assistant입니다. 지금까지의 대화 내용을 바탕으로 맥락을 이해하며 다음 질문을 생성해야 합니다. 항상 존댓말을 사용하여 정중하게 질문해 주세요.

대화 기록:
{chat_history}

사용자의 마지막 답변: {last_answer}

위의 정보를 바탕으로, 사용자의 자서전 작성을 위한 다음 질문을 생성해주세요. 이 질문은 다음 요소들을 고려해야 합니다:

1. 주제 다양성: 가족, 교육, 직업, 취미, 중요한 결정, 인간관계, 도전과 성취 등 다양한 삶의 영역을 다루세요.
2. 감정과 성찰: 단순한 사실보다는 감정과 개인적 성찰을 이끌어내는 질문을 만드세요.
3. 구체적인 에피소드: 특정 사건이나 경험에 대한 상세한 설명을 유도하세요.
4. 가치관과 신념: 개인의 가치관, 신념, 인생관을 탐구하는 질문을 포함하세요.
5. 변화와 성장: 인생의 전환점이나 중요한 변화, 개인적 성장에 대해 질문하세요.

질문은 이전 대화의 맥락을 고려하고, 더 깊이 있는 정보를 얻을 수 있어야 합니다. 항상 존댓말을 사용하여 정중하게 질문해 주세요.

생성된 질문:
"""

# PromptTemplate 객체 생성
input_prompt = PromptTemplate(input_variables=["input_text"], template=input_prompt_template)
chat_prompt = PromptTemplate(input_variables=["chat_history", "last_answer"], template=chat_prompt_template)

# 데이터 모델 정의
class UserInput(BaseModel):
    answer: str

def get_chat_history(conn) -> List[tuple]:
    """
    DB에서 모든 채팅 기록을 가져옴
    """
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT role, content FROM chat_history")
        return cursor.fetchall()
    except sqlite3.Error as e:
        raise HTTPException(status_code=500, detail=f"Database query error: {str(e)}")

def add_to_chat_history(conn, role: str, content: str):
    """
    새로운 대화 내용을 DB에 추가
    """
    try:
        cursor = conn.cursor()
        cursor.execute("INSERT INTO chat_history (role, content) VALUES (?, ?)", (role, content))
        conn.commit()
    except sqlite3.Error as e:
        raise HTTPException(status_code=500, detail=f"Database insert error: {str(e)}")

def generate_question_from_input(input_text: str) -> str:
    """
    사용자의 입력 텍스트를 바탕으로 새로운 질문을 생성
    """
    try:
        print(f"Input for OpenAI API: {input_text}")  # 디버깅 로그 추가
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "당신은 AI Assistant입니다. 사용자가 입력한 텍스트에 대한 질문을 생성해야 합니다."},
                {"role": "user", "content": input_prompt.format(input_text=input_text)}
            ],
            max_tokens=150,
            temperature=0.7
        )
        print("OpenAI API Response:", response)  # 디버깅 로그 추가
        return response['choices'][0]['message']['content'].strip()
    except OpenAIError as e:
        print(f"OpenAI API Error: {str(e)}")  # OpenAI API 관련 에러 메시지 출력
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")
    except Exception as e:
        print(f"General error in generating question from input: {str(e)}")  # 일반적인 오류 출력
        raise HTTPException(status_code=500, detail="질문 생성 중 오류가 발생했습니다.")

def generate_question_from_chat(chat_history: List[tuple], last_answer: str) -> str:
    """
    채팅 기록과 마지막 답변을 바탕으로 새로운 질문을 생성
    """
    # 채팅 기록을 문자열로 변환
    chat_history_text = "\n".join([f"{role}: {content}" for role, content in chat_history])
    try:
        response = openai.Completion.create(
            model="text-davinci-003",
            prompt=chat_prompt.format(chat_history=chat_history_text, last_answer=last_answer),
            max_tokens=150,
            temperature=0.7
        )
        return response.choices[0].text.strip()
    except OpenAIError as e:
        print(f"OpenAI API Error: {str(e)}")  # 디버깅 로그 추가
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")
    except Exception as e:
        print(f"General error in generating question from chat: {str(e)}")  # 일반적인 오류 출력
        raise HTTPException(status_code=500, detail="질문 생성 중 오류가 발생했습니다.")

# 루트 경로 엔드포인트 정의 (HTML 페이지 렌더링)
@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/generate_question")
async def generate_next_question(answer: str = Form(...), use_chat_context: bool = Form(False)):
    """
    사용자의 입력 텍스트 또는 채팅 기록을 받아 새로운 질문을 생성
    """
    try:
        with get_db_connection() as conn:
            if use_chat_context:
                # 채팅 기록을 바탕으로 질문 생성
                chat_history = get_chat_history(conn)
                print("Chat history loaded:", chat_history)  # 디버깅 로그 추가
                question = generate_question_from_chat(chat_history, answer)
            else:
                # 입력 텍스트를 바탕으로 질문 생성
                print("Generating question from input:", answer)  # 디버깅 로그 추가
                question = generate_question_from_input(answer)
            
            print("Generated question:", question)  # 디버깅 로그 추가

            add_to_chat_history(conn, "assistant", question)
            add_to_chat_history(conn, "user", answer)
        
        return {"question": question}
    except HTTPException as http_exc:
        print(f"HTTP Exception: {http_exc.detail}")
        raise http_exc  # 이미 처리된 HTTP 예외
    except Exception as e:
        # 일반적인 예외에 대한 로깅 추가
        print(f"Error generating question: {e}")  # 디버깅 로그 추가
        raise HTTPException(status_code=500, detail="질문 생성 중 오류가 발생했습니다.")

@app.get("/chat_history", response_class=HTMLResponse)
async def get_history(request: Request):
    """
    대화 기록을 반환
    """
    with get_db_connection() as conn:
        history = get_chat_history(conn)
    return templates.TemplateResponse("index.html", {"request": request, "history": history})

@app.delete("/clear_chat_history")
async def clear_chat_history():
    """
    대화 기록을 모두 삭제
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM chat_history")
            conn.commit()
        return {"message": "Chat history cleared."}
    except sqlite3.Error as e:
        raise HTTPException(status_code=500, detail=f"Database deletion error: {str(e)}")
