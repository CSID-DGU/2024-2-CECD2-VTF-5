import asyncio
import json
import sqlite3
import os
import requests
import openai
from langchain.prompts import PromptTemplate
from pydantic import BaseModel

from sqlalchemy.orm import Session
from openai import OpenAIError
from dotenv import load_dotenv
from typing import List, Optional
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi import Request

# 랭체인 관련
from langchain.chains import ConversationChain # 이거 쓰지 말기 deprecated됨
from langchain.memory import ConversationSummaryBufferMemory
from langchain.memory import ConversationSummaryMemory

from langchain_openai import ChatOpenAI
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_core.chat_history import InMemoryChatMessageHistory

from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from datetime import datetime, timedelta
import jwt as pyjwt  # pyjwt 패키지를 사용하고 있음

from ..config.test_database import engine, SessionLocal  # engine과 SessionLocal만 임포트
from ..dto.memberDto import LoginRequest

from ..entity import member
from ..dto import memberDto
from BackEnd.entity.base import Base  # Base는 모든 엔티티가 상속하는 기본 클래스


# 환경 변수 로드
# load_dotenv()
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
load_dotenv(dotenv_path=dotenv_path)

# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     # 애플리케이션 시작 시 실행할 코드
#     member.Base.metadata.create_all(bind=engine)  # DB 테이블 생성
#     yield

# 최상위 2024~~에서 uvicorn BackEnd.app.main:app --reload
# app = FastAPI(lifespan=lifespan) # 오류나면 이거로 트라이
app = FastAPI()
# templates = Jinja2Templates(directory="BackEnd/app/templates")
templates = Jinja2Templates(directory=os.path.join(os.path.dirname(__file__), "templates"))

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용 (개발 중에만 사용)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# OpenAI API 키를 환경 변수에서 가져오기
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
client_id = os.getenv("YOUR_CLIENT_ID")
client_secret = os.getenv("YOUR_CLIENT_SECRET")
openai.api_key = OPENAI_API_KEY # 리펙토링할 때 정리하기

# OpenAI 클라이언트 초기화
# client = OpenAI(api_key=os.getenv("OPENAI_API_KEY")) # csbm 쓰기 전임.
client = ChatOpenAI(api_key=OPENAI_API_KEY)

# 요약 기반 메모리 생성 (200 토큰 제한)
memory = ConversationSummaryMemory(
    llm=client,
    max_token_limit=200,  # 요약의 기준이 되는 토큰 길이를 설정합니다.
    return_messages=True,
)

if not OPENAI_API_KEY:
    raise ValueError("OpenAI API 키가 없습니다  .env 파일을 다시 살펴보세요")


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
input_prompt_template = """
당신은 자서전 작성을 돕는 AI Assistant입니다. 노인의 삶의 기억을 되살리고, 중요한 순간들을 기록할 수 있도록 돕는 질문을 생성해야 합니다.

입력 텍스트:
{input_text}

위의 텍스트를 바탕으로, 다음과 같은 주제로 2개의 질문을 생성하세요:
- 중요한 기억이나 사건
- 가족과의 추억
- 인생의 교훈과 가치

질문은 노인이 더 많은 기억을 떠올릴 수 있도록 구체적이고 따뜻한 어조로 작성되어야 합니다.

생성된 질문:
"""


chat_prompt_template = """
당신은 자서전 작성을 돕는 AI Assistant입니다. 지금까지의 대화 내용을 바탕으로 노인의 삶의 경험과 기억을 되살릴 수 있는 질문을 생성해야 합니다.

대화 기록:
{chat_history}

사용자의 마지막 답변: {last_answer}

위의 정보를 바탕으로, 노인이 자신의 이야기를 더 깊이 생각하고 이야기할 수 있는 다음 질문을 2개 생성하세요. 질문은 친절하고 따뜻한 어조로 작성되어야 하며, 다음 주제를 다룰 수 있습니다:
- 인생의 중요한 사건
- 어린 시절의 기억
- 가족, 친구와의 추억
- 인생에서 가장 자랑스러웠던 순간

생성된 질문:
"""


# PromptTemplate 객체 생성
input_prompt = PromptTemplate(input_variables=["input_text"], template=input_prompt_template)
chat_prompt = PromptTemplate(input_variables=["chat_history", "last_answer"], template=chat_prompt_template)


# 데이터 모델 정의
class member_input(BaseModel):
    answer: str


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
        print("STT 결과:", response.text)

        # JSON 응답인지 확인하고 파싱 (txt만 뽑기)
        try:
            stt_result = json.loads(response.text)
            input_text = stt_result.get("text", "")
        except json.JSONDecodeError:
            input_text = response.text  # JSON 파싱 실패 시 일반 텍스트로 사용

        return generate_question(input_text)  # 최종 질문 반환
    else:
        print("Error:", response.text)
        raise HTTPException(status_code=500, detail="STT 변환 중 오류가 발생했습니다.")


""" STT 결과값 가지고 input에 넣기 """
def generate_question(user_input: str) -> dict:
    """
    사용자의 입력 텍스트를 바탕으로 자서전 작성에 필요한 질문을 생성하고, 두 개의 선택지로 반환
    """
    try:
        print(f"\n사용자의 입력값: {user_input}")  # 디버깅 로그 추가

        # 메모리 기반의 대화 기록 불러오기
        memory_summary = memory.load_memory_variables({})
        chat_history = memory_summary.get("history", "")

        # 자서전 작성용 프롬프트를 사용하여 질문 생성
        prompt = chat_prompt.format(chat_history=chat_history, last_answer=user_input)
        response = client.invoke(prompt)  # 자서전 프롬프트로 LLM 호출

        # 응답이 AIMessage 형식인 경우, content 속성 추출
        if hasattr(response, 'content'):
            response_text = response.content
        elif isinstance(response, list) and len(response) > 0:
            response_text = response[0].content  # 리스트일 경우 첫 번째 항목의 content 추출
        else:
            raise ValueError("응답이 예상한 문자열 형식이 아닙니다.")

        # 응답을 줄 바꿈으로 분할하고 상위 2개의 질문만 추출
        questions = response_text.strip().split("\n")
        questions = [q.strip() for q in questions if q.strip()]  # 빈 줄 제거
        questions = questions[:2]  # 최대 2개만 선택

        # questions[0]이 질문1번, questions[1]이 질문2번임.
        print("질문1번:", questions[0])
        print("질문2번:", questions[1])

        # 메모리 업데이트 (사용자 답변만 저장) -> 추후 저장공간 문제 우려
        memory.save_context({"input": user_input}, {"output": ""}) # AI 응답은 저장하지 않음. output은 일단 넘겨주긴 해야함. 빈 상태로 넘김.

        # 현재 메모리 상태 출력 (요약된 내용 확인)
        print("현재 메모리 요약:", memory_summary)

        # 두 개의 질문을 JSON 형식으로 반환. 쓰기 편하라고(?) 딕셔너리로 넘김
        return {"question1": questions[0], "question2": questions[1]}

    except ValueError as e:
        print(f"Validation Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Validation error: {str(e)}")
    except asyncio.exceptions.CancelledError:
        print("요청이 취소되었습니다.")
        raise HTTPException(status_code=500, detail="요청이 취소되었습니다.")
    except OpenAIError as e:
        print(f"OpenAI API Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"OpenAI API 오류: {str(e)}")
    except Exception as e:
        print(f"General error in generating question from input: {str(e)}")
        raise HTTPException(status_code=500, detail="질문 생성 중 오류가 발생했습니다.")
#################################################################################

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
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="signIn")


# 비밀번호 해싱 함수
def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


# 비밀번호 검증 함수
def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


# jwt말고, pyjwt 써야함. 충돌 가능해서
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return pyjwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_access_token(token: str):
    try:
        payload = pyjwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except pyjwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except pyjwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

# 회원가입 엔드포인트
@app.post("/signup", response_model=memberDto.Member)
def signup(member_data: memberDto.MemberCreate, db: Session = Depends(get_db)):
    db_member = db.query(member.Member).filter(member.Member.login_id == member_data.login_id).first()
    if db_member:
        raise HTTPException(status_code=400, detail="아이디가 이미 존재합니다.")

    hashed_password = get_password_hash(member_data.password)
    new_member = member.Member(
        name = member_data.name,
        login_id=member_data.login_id,
        password=hashed_password, # 해시값
        email=member_data.email,
        birth=member_data.birth,
        is_male=member_data.is_male,
        is_married=member_data.is_married,
        has_child=member_data.has_child
    )
    db.add(new_member)
    db.commit()
    db.refresh(new_member)
    return new_member


# 로그인 엔드포인트 (JWT 토큰 발급)
@app.post("/signIn", response_model=memberDto.Token)
def login_for_access_token(login_data: LoginRequest, db: Session = Depends(get_db)):
    # 사용자 조회
    present_member = db.query(member.Member).filter(member.Member.login_id == login_data.login_id).first()

    # 디버깅 로그
    print("Queried member:", present_member)

    # 아이디 검증
    if not present_member:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    # 비밀번호 검증
    if not verify_password(login_data.password, present_member.password):
        raise HTTPException(status_code=401, detail="비밀번호가 잘못되었습니다.")

    # JWT 토큰 발급
    access_token = create_access_token(data={"sub": present_member.login_id})
    # 사용자 정보 반환
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "name": present_member.name,  # 사용자 이름 반환
        "id": present_member.login_id  # 사용자 ID 반환
    }


# 루트 경로 엔드포인트 정의 (HTML 페이지 렌더링)
@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


@app.get("/signup", response_class=HTMLResponse)
async def signup_page(request: Request):
    return templates.TemplateResponse("signup.html", {"request": request})

@app.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/generate_question", response_class=HTMLResponse)
async def generate_question_page(request: Request):
    return templates.TemplateResponse("generate_question.html", {"request": request})