import os
import sqlite3
from pydantic import BaseModel
import openai
import requests

from openai import OpenAIError  # OpenAI 예외 처리 클래스

from langchain.prompts import PromptTemplate

from dotenv import load_dotenv
from typing import List
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi import Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware

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
client_id = os.getenv("YOUR_CLIENT_ID")
client_secret = os.getenv("YOUR_CLIENT_SECRET")

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


# 루트 경로 엔드포인트 정의 (HTML 페이지 렌더링)
@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


""" Naver STT 라이브러리 """
@app.post("/generate_question")
async def generateQuestionByNaverSTT(recordFile: UploadFile = File(...)):
    # 음성 파일을 Naver STT API로 보내기
    url = "https://naveropenapi.apigw.ntruss.com/recog/v1/stt?lang=Kor"

    # 파일을 비동기로 읽어서 Naver STT API에 전송
    data = await recordFile.read()

    # headers는 바꾸면 안됨.
    headers = {
        "X-NCP-APIGW-API-KEY-ID": client_id,
        "X-NCP-APIGW-API-KEY": client_secret,
        "Content-Type": "application/octet-stream"
    }

    response = requests.post(url, data=data, headers=headers)
    rescode = response.status_code


    if (rescode == 200):
        print("STT 결과 : ", response.text)
    else:
        print("Error : " + response.text)

    return generate_question(response.text) # 최종 질문 반환


""" STT 결과값 가지고 input에 넣기 """
def generate_question(input_text: str) -> str:
    """
    사용자의 입력 텍스트를 바탕으로 새로운 질문을 생성
    """

    try:
        print(f"\n사용자의 입력값 : {input_text}")  # 디버깅 로그 추가
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "당신은 AI Assistant입니다. 사용자가 입력한 텍스트에 대한 질문을 생성해야 합니다."},
                {"role": "user", "content": input_prompt.format(input_text=input_text)}
            ],
            max_tokens=150,
            temperature=0.7
        )
        print("\n질문 생성 결과 : ", response['choices'][0]['message']['content'].strip())  # 디버깅 로그 추가
        return response['choices'][0]['message']['content'].strip()
    except OpenAIError as e:
        print(f"OpenAI API Error: {str(e)}")  # OpenAI API 관련 에러 메시지 출력
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")
    except Exception as e:
        print(f"General error in generating question from input: {str(e)}")  # 일반적인 오류 출력
        raise HTTPException(status_code=500, detail="질문 생성 중 오류가 발생했습니다.")
#################################################################################
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