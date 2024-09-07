import os
import sqlite3
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from openai import OpenAI
from langchain.prompts import PromptTemplate

# FastAPI 앱 생성
app = FastAPI()

# .env 파일에서 환경 변수 로드
load_dotenv()

# 환경 변수에서 OpenAI API 키 가져오기
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# OpenAI 클라이언트 초기화
client = OpenAI(api_key=OPENAI_API_KEY)

# SQLite 데이터베이스 연결 설정
conn = sqlite3.connect('chat_history.db', check_same_thread=False)
cursor = conn.cursor()

# 채팅 기록을 저장할 테이블 생성
cursor.execute('''CREATE TABLE IF NOT EXISTS chat_history
                  (id INTEGER PRIMARY KEY AUTOINCREMENT,
                   role TEXT,
                   content TEXT)''')
conn.commit()

# 프롬프트 템플릿 정의
template = """당신은 AI 자서전 작성을 돕는 assistant입니다. 지금까지의 대화 내용을 바탕으로 맥락을 이해하며 다음 질문을 생성해야 합니다. 항상 존댓말을 사용하여 정중하게 질문해 주세요.

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
prompt = PromptTemplate(input_variables=["chat_history", "last_answer"], template=template)


# 데이터 모델 정의
class UserInput(BaseModel):
    answer: str


def get_chat_history():
    """
    DB에서 모든 채팅 기록을 가져옴
    """
    cursor.execute("SELECT role, content FROM chat_history")
    return cursor.fetchall()


def add_to_chat_history(role, content):
    """
    새로운 대화 내용을 DB에 추가
    """
    cursor.execute("INSERT INTO chat_history (role, content) VALUES (?, ?)", (role, content))
    conn.commit()


def generate_question(chat_history, last_answer):
    """
    채팅 기록과 마지막 답변을 바탕으로 새로운 질문을 생성
    """
    # 채팅 기록을 문자열로 변환
    chat_history_text = "\n".join([f"{role}: {content}" for role, content in chat_history])

    # OpenAI API를 사용하여 새로운 질문 생성
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": prompt.format(chat_history=chat_history_text, last_answer=last_answer)},
            {"role": "user", "content": "다음 질문을 생성해주세요."}
        ],
        temperature=0.7  # 응답의 창의성 조절 (0.0 ~ 1.0), 1에 가까울수록 창의적이고 0에 가까울수록 기존 질문과 유사한 질문을 생성함
    )
    return response.choices[0].message.content.strip()  # Pydantic 모델로 반환


@app.post("/generate_question")
async def generate_next_question(user_input: UserInput):
    """
    사용자의 마지막 답변을 받아 새로운 질문을 생성
    """
    chat_history = get_chat_history()
    question = generate_question(chat_history, user_input.answer)
    add_to_chat_history("assistant", question)
    add_to_chat_history("user", user_input.answer)
    return {"question": question}


@app.get("/chat_history")
async def get_history():
    """
    대화 기록을 반환
    """
    history = get_chat_history()
    return {"chat_history": history}


@app.delete("/clear_chat_history")
async def clear_chat_history():
    """
    대화 기록을 모두 삭제
    """
    cursor.execute("DELETE FROM chat_history")
    conn.commit()
    return {"message": "Chat history cleared."}
