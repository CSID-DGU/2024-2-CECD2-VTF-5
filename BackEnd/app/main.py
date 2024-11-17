import asyncio, json, sqlite3, os, requests, io
from dotenv import load_dotenv
from typing import Optional
from pydantic import BaseModel

# JWT 관련
import jwt as pyjwt  # pyjwt 패키지를 사용하고 있음. jwt말고, pyjwt 써야함. 충돌 가능해서
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext

# 테이블 관련
from sqlalchemy.orm import Session

# 랭체인 관련
from openai import OpenAIError
from langchain.memory import ConversationSummaryMemory
from langchain_openai import ChatOpenAI
from langchain.prompts import PromptTemplate

# FastAPI 관련
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, status, Request
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta

# html 템플릿 관련 (안쓰니까 일단 주석처리)
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse

# py 파일들 불러오기
from ..config.test_database import SessionLocal
from ..dto.memberDto import LoginRequest
from ..entity import member
from ..dto import memberDto
from ..service import tts, stt
from ..prompt import complete_prompt, member_prompt

# 환경 변수 로드
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
load_dotenv(dotenv_path=dotenv_path)

# OpenAI API 키를 환경 변수에서 가져오기
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Naver STT key
client_id = os.getenv("YOUR_CLIENT_ID")
client_secret = os.getenv("YOUR_CLIENT_SECRET")

# JWT 설정
SECRET_KEY = os.getenv("SECRET_KEY", "your_secret_key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# 비밀번호 관련
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")  # 비밀번호 해싱을 위한 설정

# html 템플릿 관련
# templates = Jinja2Templates(directory=os.path.join(os.path.dirname(__file__), "templates"))

# 최상위 2024~~에서 uvicorn BackEnd.app.main:app --reload
app = FastAPI()
client = ChatOpenAI(api_key=OPENAI_API_KEY)  # OpenAI 클라이언트 초기화

""" CORS 설정 추가 """
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용 (개발 중에만 사용)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

""" 요약 기반 메모리 생성 (200 토큰 제한) """
memory = ConversationSummaryMemory(
    llm=client,
    max_token_limit=200,  # 요약의 기준이 되는 토큰 길이를 설정합니다.
    return_messages=True,
)

def get_password_hash(password: str) -> str:
    """
    JWT : 비밀번호 해싱 함수
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    JWT : 비밀번호 검증 함수
    """
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """
    JWT : 토큰 생성하기
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return pyjwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_access_token(token: str):
    """
    JWT : 토큰 디코드 하기
    """
    try:
        payload = pyjwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except pyjwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except pyjwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


def get_db():
    """
    의존성 주입을 위한 DB 세션 함수
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


""" PromptTemplate 객체 생성 """
member_life_prompt = PromptTemplate(input_variables=["chat_history", "last_answer"], template=member_prompt.life_prompt)
autobiography_prompt = PromptTemplate(input_variables=["name", "age", "responses"],
                                      template=complete_prompt.biography_prompt)

class SpeechModel(BaseModel):
    """
    STT, TTS 입력 모델 정의
    """
    stt_input: str = None  # STT에서 사용, 선택적
    tts_input: str = None  # TTS에서 사용, 선택적

@app.post("/generate_question")
async def generate_question(input_data: SpeechModel, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    """
    gpt에게 질문 생성 요청
    """
    stt_input = input_data.stt_input  # JSON Body에서 텍스트 추출
    
    # 사용자 ID 추출
    try:
        token_data = decode_access_token(token)
        user_id = token_data.get("sub")

        if not user_id:
            raise HTTPException(status_code=401, detail="유효하지 않은 사용자 토큰입니다.")
    except HTTPException as e:
        print(f"토큰 오류: {str(e)}")
        raise e

    try:
        print(f"\n사용자의 입력값: {stt_input}")

        # 1. 기존 요약 불러오기 (누적된 대화 맥락)
        memory_summary = memory.load_memory_variables({})
        existing_summary = memory_summary.get("history", "")

        # 2. 새로운 사용자 입력을 기존 요약에 누적하여 새로운 요약 업데이트
        updated_summary = f"{existing_summary}\n사용자 답변: {stt_input}"

        # 3. 누적된 요약을 바탕으로 질문 생성
        prompt = member_life_prompt.format(chat_history=updated_summary, last_answer=stt_input)
        response = client.invoke(prompt)

        # 응답에서 질문을 추출
        if hasattr(response, 'content'):
            response_text = response.content
        elif isinstance(response, list) and len(response) > 0:
            response_text = response[0].content
        else:
            raise ValueError("응답 형식이 예상과 다릅니다.")

        # 응답을 줄바꿈 기준으로 3개 질문 추출
        questions = response_text.strip().split("\n")
        questions = [q.strip() for q in questions if q.strip()][:3]

        for i, question in enumerate(questions):
            print(f"질문 {i + 1}: {question}")

        # 4. 사용자 답변이 포함된 요약을 메모리에 저장하여 누적 유지
        memory.save_context({"input": stt_input}, {"output": updated_summary})

        # 사용자 summary 필드 업데이트
        update_user_summary(db, user_id, updated_summary)

        # 질문과 누적된 요약 반환
        return {
            "questions": questions,
            "summary": updated_summary
        }
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


def update_user_summary(db: Session, user_id: str, summary_text: str):
    """
    사용자의 summary 필드를 요약본으로 업데이트합니다.
    """
    # summary_text를 문자열로 변환 (예: 리스트나 복잡한 객체가 아닌 문자열로만 저장 가능)
    if isinstance(summary_text, list):
        # 리스트 형식이라면, 각 항목을 문자열로 변환하고 합쳐서 저장
        summary_text = "\n".join(str(item) for item in summary_text)

    user = db.query(member.Member).filter(member.Member.login_id == user_id).first()
    if user:
        user.summary = summary_text  # summary 필드에 업데이트된 텍스트 저장
        db.commit()
        print(f"사용자 {user_id}의 summary가 업데이트되었습니다.")
    else:
        print(f"사용자 {user_id}를 찾을 수 없습니다.")
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")


@app.post("/stt")
async def speech_to_text(recordFile: UploadFile = File(...)):
    """
    STT로 질문 txt 뽑아내기
    """
    return await stt.stt_request(recordFile, client_id, client_secret)


@app.post("/tts")
async def text_to_speech(request: SpeechModel):
    """
    TTS로 질문내역 음성으로 들려주기
    """
    pass

@app.post("/signup", response_model=memberDto.Member)
def signup(member_data: memberDto.MemberCreate, db: Session = Depends(get_db)):
    """
    사용자 회원가입 하기
    """
    db_member = db.query(member.Member).filter(member.Member.login_id == member_data.login_id).first()
    if db_member:
        raise HTTPException(status_code=400, detail="아이디가 이미 존재합니다.")

    hashed_password = get_password_hash(member_data.password)
    new_member = member.Member(
        name=member_data.name,
        login_id=member_data.login_id,
        password=hashed_password,  # 해시값
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


@app.post("/login", response_model=memberDto.Token)
def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """
    사용자 로그인 후 JWT 토큰 발급
    """

    # 사용자 조회
    present_member = db.query(member.Member).filter(member.Member.login_id == login_data.login_id).first()

    # 디버깅 로그
    print("현재 사용자 : ", present_member)

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
        "login_id": login_data.login_id
    }

def calculate_age(birth_date: str) -> int:
    """
    나이 계산 함수
    """
    try:
        # 날짜 형식이 'YYYYMMDD'라면 %Y%m%d로 파싱
        birth_date_obj = datetime.strptime(birth_date, "%Y%m%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format, expected 'YYYYMMDD'.")

    today = datetime.today()
    age = today.year - birth_date_obj.year - ((today.month, today.day) < (birth_date_obj.month, birth_date_obj.day))
    return age


@app.post("/complete")
def process_autobiography(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """
    완성된 자서전 텍스트를 요약하여 반환
    사용자 정보와 요약 내용을 가져옴
    """
    print(f"Received token: {token}")  # 받은 토큰 출력
    try:
        # 토큰을 디코드하여 사용자 정보 추출
        decoded_token = decode_access_token(token)
        user_id = decoded_token.get("sub")  # JWT payload에서 'sub' 필드가 사용자 ID로 가정
        print(f"Decoded user_id: {user_id}")  # 디코딩된 user_id 출력

        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token: User ID not found.")

        # 사용자 정보 가져오기
        user = db.query(member.Member).filter(member.Member.login_id == user_id).first()

        if not user:
            raise HTTPException(status_code=404, detail="User not found.")

        # 사용자 이름과 요약 (summary) 값 사용
        user_name = user.name
        user_summary = user.summary  # DB에서 가져온 summary
        user_birth = user.birth  # 사용자 생년월일

        # 나이 계산 (생년월일을 기준으로 나이 계산)
        user_age = calculate_age(user_birth)

        if not user_summary:
            raise HTTPException(status_code=400, detail="User has not provided a summary.")

        # PromptTemplate 준비
        formatted_prompt = autobiography_prompt.format(
            name=user_name,
            age=user_age,
            responses=user_summary
        )

        # OpenAI 호출
        response = client.invoke(formatted_prompt)

        # 결과 반환
        return {"autobiography": response}

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing autobiography: {str(e)}")

################################################################################
# 루트 경로 엔드포인트 정의 (HTML 페이지 렌더링)
# @app.get("/", response_class=HTMLResponse)
# async def read_root(request: Request):
#     return templates.TemplateResponse("index.html", {"request": request})
#
# @app.get("/signup", response_class=HTMLResponse)
# async def signup_page(request: Request):
#     return templates.TemplateResponse("signup.html", {"request": request})
#
# @app.get("/login", response_class=HTMLResponse)
# async def login_page(request: Request):
#     return templates.TemplateResponse("login.html", {"request": request})
#
# @app.get("/generate_question", response_class=HTMLResponse)
# async def generate_question_page(request: Request):
#     return templates.TemplateResponse("generate_question.html", {"request": request})