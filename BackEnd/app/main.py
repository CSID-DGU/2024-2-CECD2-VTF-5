import os
import sys
import sqlite3
from langchain.prompts import PromptTemplate
from pydantic import BaseModel
import openai
from openai import OpenAI

import requests
from sqlalchemy.orm import Session
from openai import OpenAIError
from dotenv import load_dotenv
from typing import List, Optional
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi import Request
from contextlib import asynccontextmanager

from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from datetime import datetime, timedelta
import jwt
from ..config.test_database import engine, SessionLocal  # engine과 SessionLocal만 임포트

from ..entity import User
from ..dto import UserDto

# 환경 변수 로드
# load_dotenv()
# load_dotenv(dotenv_path="../.env")
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
load_dotenv(dotenv_path=dotenv_path)

# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     # 애플리케이션 시작 시 실행할 코드
#     User.Base.metadata.create_all(bind=engine)  # DB 테이블 생성
#     yield


# 최상위 2024~~에서 uvicorn BackEnd.app.main:app --reload
# FastAPI 앱 생성
app = FastAPI()
# app = FastAPI(lifespan=lifespan)


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

# OpenAI 클라이언트 초기화
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

if not OPENAI_API_KEY:
    raise ValueError("OpenAI API Key is not set. Please set it in the .env file.")

# OpenAI 클라이언트 초기화
openai.api_key = OPENAI_API_KEY


# SQLite 데이터베이스 연결 설정
def get_db_connection():
    try:
        conn = sqlite3.connect('../chat_history.db', check_same_thread=False)
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

chat_prompt_template = """당신은 AI 자서전 작성을 돕는 assistant입니다. 지금까지의 대화 내용을 바탕으로 맥락을 이해하며 다음 질문을 생성해야 합니다.

대화 기록:
{chat_history}

사용자의 마지막 답변: {last_answer}

위의 정보를 바탕으로, 자서전 작성을 위한 다음 질문을 생성하세요.
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
async def generate_question_by_naver_stt(recordFile: UploadFile = File(...)):
    # 음성 파일을 Naver STT API로 보내기
    url = "https://naveropenapi.apigw.ntruss.com/recog/v1/stt?lang=Kor"
    data = await recordFile.read()
    headers = {
        "X-NCP-APIGW-API-KEY-ID": client_id,
        "X-NCP-APIGW-API-KEY": client_secret,
        "Content-Type": "application/octet-stream"
    }
    response = requests.post(url, data=data, headers=headers)
    rescode = response.status_code
    if rescode == 200:
        print("STT 결과 : ", response.text)
    else:
        print("Error : " + response.text)
    return generate_question(response.text)  # 최종 질문 반환


""" STT 결과값 가지고 input에 넣기 """
def generate_question(input_text: str) -> str:
    """
    사용자의 입력 텍스트를 바탕으로 새로운 질문을 생성
    """
    try:
        print(f"\n사용자의 입력값 : {input_text}")  # 디버깅 로그 추가
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{
                "role": "user",
                "content": f"당신은 AI Assistant입니다. 사용자가 입력한 텍스트에 대한 질문을 생성해야 합니다.\n\n입력 텍스트:\n{input_text}"
            }],
            max_tokens=150,
            temperature=0.7
        )
        return response.choices[0].message.content.strip()
    except OpenAIError as e:
        print(f"OpenAI API Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")
    except Exception as e:
        print(f"General error in generating question from input: {str(e)}")
        raise HTTPException(status_code=500, detail="질문 생성 중 오류가 발생했습니다.")



#################################################################################
@app.get("/chat_history", response_class=HTMLResponse)
async def get_history(request: Request):
    with get_db_connection() as conn:
        history = get_chat_history(conn)
    return templates.TemplateResponse("index.html", {"request": request, "history": history})


@app.delete("/clear_chat_history")
async def clear_chat_history():
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM chat_history")
            conn.commit()
        return {"message": "Chat history cleared."}
    except sqlite3.Error as e:
        raise HTTPException(status_code=500, detail=f"Database deletion error: {str(e)}")


# # PostgreSQL 또는 SQLite 데이터베이스 연결 설정
# @app.on_event("startup")
# def on_startup():
#     User.Base.metadata.create_all(bind=engine)



# 의존성 주입을 위한 DB 세션 함수
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# 비밀번호 해싱을 위한 설정
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT 설정
SECRET_KEY = os.getenv("SECRET_KEY", "your_secret_key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


# 비밀번호 해싱 함수
def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


# 비밀번호 검증 함수
def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


# JWT 토큰 생성 함수
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


# JWT 토큰 디코딩 함수
def decode_access_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


# 회원가입 엔드포인트
@app.post("/signup", response_model=UserDto.User)
def signup(user: UserDto.UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User.User).filter(User.User.아이디 == user.아이디).first()
    if db_user:
        raise HTTPException(status_code=400, detail="아이디가 이미 존재합니다.")

    hashed_password = get_password_hash(user.비밀번호)
    new_user = User.User(
        이름=user.이름,
        아이디=user.아이디,
        비밀번호=hashed_password,
        이메일=user.이메일,
        생년월일=user.생년월일,
        성별_남성여부=user.성별_남성여부,
        결혼여부=user.결혼여부,
        자녀유무=user.자녀유무
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


# 로그인 엔드포인트 (JWT 토큰 발급)
@app.post("/token", response_model=UserDto.Token)
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User.User).filter(User.User.아이디 == form_data.username).first()

    if not user or not verify_password(form_data.password, user.비밀번호):
        raise HTTPException(status_code=401, detail="아이디 또는 비밀번호가 잘못되었습니다.")

    access_token = create_access_token(data={"sub": user.아이디})
    return {"access_token": access_token, "token_type": "bearer"}


# 로그인된 유저 정보 확인
@app.get("/users/me", response_model=UserDto.User)
def read_users_me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_access_token(token)
    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(status_code=401, detail="토큰이 유효하지 않습니다.")

    user = db.query(User.User).filter(User.User.아이디 == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    return user


from fastapi.responses import HTMLResponse


@app.get("/signup", response_class=HTMLResponse)
async def signup_page():
    return """
    <!DOCTYPE html>
    <html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>회원가입</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f0f0f0;
            }
            h1 {
                text-align: center;
                color: #333;
            }
            form {
                display: flex;
                flex-direction: column;
                gap: 15px;
                background-color: white;
                padding: 20px;
                border-radius: 5px;
                border: 1px solid #ccc;
            }
            input[type="text"], input[type="password"], input[type="email"], select {
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 5px;
                font-size: 16px;
            }
            button {
                padding: 10px;
                background-color: #4CAF50;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                font-size: 16px;
            }
            button:hover {
                background-color: #45a049;
            }
        </style>
    </head>
    <body>
        <h1>회원가입</h1>
        <form id="signup-form">
            <label for="name">이름:</label>
            <input type="text" id="name" name="name" required>

            <label for="username">아이디:</label>
            <input type="text" id="username" name="username" required>

            <label for="email">이메일:</label>
            <input type="email" id="email" name="email" required>

            <label for="password">비밀번호:</label>
            <input type="password" id="password" name="password" required>

            <label for="birthdate">생년월일:</label>
            <input type="text" id="birthdate" name="birthdate" required placeholder="예: 2000-01-01">

            <label for="gender">성별:</label>
            <select id="gender" name="gender" required>
                <option value="true">남성</option>
                <option value="false">여성</option>
            </select>

            <label for="married">결혼 여부:</label>
            <select id="married" name="married" required>
                <option value="true">예</option>
                <option value="false">아니요</option>
            </select>

            <label for="children">자녀 유무:</label>
            <select id="children" name="children" required>
                <option value="true">예</option>
                <option value="false">아니요</option>
            </select>

            <button type="submit">회원가입</button>
        </form>

        <script>
            document.getElementById('signup-form').addEventListener('submit', function(event) {
                event.preventDefault();

                const name = document.getElementById('name').value;
                const username = document.getElementById('username').value;
                const email = document.getElementById('email').value;
                const password = document.getElementById('password').value;
                const birthdate = document.getElementById('birthdate').value;
                const gender = document.getElementById('gender').value === 'true';
                const married = document.getElementById('married').value === 'true';
                const children = document.getElementById('children').value === 'true';

                fetch('/signup', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        이름: name,
                        아이디: username,
                        이메일: email,
                        비밀번호: password,
                        생년월일: birthdate,
                        성별_남성여부: gender,
                        결혼여부: married,
                        자녀유무: children
                    })
                })
                .then(response => response.json())
                .then(data => {
                    alert("회원가입이 완료되었습니다!");
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert("회원가입 중 오류가 발생했습니다.");
                });
            });
        </script>
    </body>
    </html>
    """


@app.post("/signup", response_model=UserDto.User)
def signup(user: UserDto.UserCreate, db: Session = Depends(get_db)):
    # 아이디 중복 확인
    db_user = db.query(User.User).filter(User.User.아이디 == user.아이디).first()
    if db_user:
        raise HTTPException(status_code=400, detail="아이디가 이미 존재합니다.")

    # 이메일 중복 확인
    db_email = db.query(User.User).filter(User.User.이메일 == user.이메일).first()
    if db_email:
        raise HTTPException(status_code=400, detail="이메일이 이미 사용 중입니다.")

    # 비밀번호 해싱 및 새로운 유저 생성
    hashed_password = get_password_hash(user.비밀번호)
    new_user = User.User(
        이름=user.이름,
        아이디=user.아이디,
        비밀번호=hashed_password,
        이메일=user.이메일,
        생년월일=user.생년월일,
        성별_남성여부=user.성별_남성여부,
        결혼여부=user.결혼여부,
        자녀유무=user.자녀유무
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user