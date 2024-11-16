import asyncio, json, sqlite3, os, requests
from dotenv import load_dotenv

# JWT 관련
import jwt as pyjwt  # pyjwt 패키지를 사용하고 있음. jwt말고, pyjwt 써야함. 충돌 가능해서

from openai import OpenAIError
from typing import Optional

# 랭체인 관련
from langchain.memory import ConversationSummaryMemory
from langchain_openai import ChatOpenAI
from langchain.prompts import PromptTemplate

# FastAPI 관련
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, status, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from datetime import datetime, timedelta

# SQL 관련
from sqlalchemy.orm import Session

from pydantic import BaseModel


from ..config.test_database import SessionLocal
from ..dto.memberDto import LoginRequest
from ..entity import member
from ..dto import memberDto


# 환경 변수 로드
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
load_dotenv(dotenv_path=dotenv_path)

# OpenAI API 키를 환경 변수에서 가져오기
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Naver STT 시크릿키
client_id = os.getenv("YOUR_CLIENT_ID")
client_secret = os.getenv("YOUR_CLIENT_SECRET")

# JWT 설정
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# 비밀번호 해싱을 위한 설정
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 최상위 2024~~에서 uvicorn BackEnd.app.main:app --reload
app = FastAPI()
templates = Jinja2Templates(directory=os.path.join(os.path.dirname(__file__), "templates"))
client = ChatOpenAI(api_key=OPENAI_API_KEY) # OpenAI 클라이언트 초기화

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용 (개발 중에만 사용)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 요약 기반 메모리 생성 (200 토큰 제한)
memory = ConversationSummaryMemory(
    llm=client,
    max_token_limit=200,  # 요약의 기준이 되는 토큰 길이를 설정합니다.
    return_messages=True,
)

# 의존성 주입을 위한 DB 세션 함수
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# JWT : 비밀번호 해싱 함수
def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

# JWT : 비밀번호 검증 함수
def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# JWT : 토큰 생성하기
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return pyjwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# JWT : 토큰 디코드 하기
def decode_access_token(token: str):
    try:
        payload = pyjwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except pyjwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except pyjwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


chat_prompt_template = """
당신은 자서전 작성을 돕는 AI Assistant입니다. 지금까지의 대화 내용을 바탕으로 노인의 삶의 경험과 기억을 되살릴 수 있는 질문을 생성해야 합니다.

대화 기록:
{chat_history}

사용자의 마지막 답변: {last_answer}

위의 정보를 바탕으로, 노인이 자신의 이야기를 더 깊이 생각하고 이야기할 수 있는 다음 질문을 3개 생성하세요. 질문은 친절하고 따뜻한 어조로 작성되어야 하며, 다음 주제를 다룰 수 있습니다:
- 인생의 중요한 사건
- 어린 시절의 기억
- 가족, 친구와의 추억
- 인생에서 가장 자랑스러웠던 순간

생성된 질문:
"""


autobiography_output_prompt = """
당신은 자서전 작성을 돕는 AI Assistant입니다. 아래 데이터를 바탕으로 자연스럽고 감성적인 자서전을 작성하세요.

사용자 정보:
- 이름: {name}
- 나이: {age}
- 주요 대답 내용: {responses}

출력 조건:
1. 자서전은 아래 느낌을 따릅니다:
   - 어린 시절부터 현재까지의 삶을 자연스럽게 연결하며 서술.
   - 감성적이고 시적인 어조를 사용.
   - 독자에게 따뜻한 여운을 남기는 방식으로 마무리.

2. 항상 내용을 매끄럽게 연결하세요.



출력 결과:
"""

# PromptTemplate 객체 생성
chat_prompt = PromptTemplate(input_variables=["chat_history", "last_answer"], template=chat_prompt_template)
autobiography_prompt = PromptTemplate(input_variables=["name", "age", "responses"], template=autobiography_output_prompt)
################################################################################
""" Naver STT 라이브러리 """
@app.post("/stt")
async def speech_to_text(
    recordFile: UploadFile = File(...),
):
    # 음성 파일을 Naver STT API로 보내기
    url = "https://naveropenapi.apigw.ntruss.com/recog/v1/stt?lang=Kor"
    data = await recordFile.read()
    headers = {
        "X-NCP-APIGW-API-KEY-ID": client_id,
        "X-NCP-APIGW-API-KEY": client_secret,
        "Content-Type": "application/octet-stream"
    }
    response = requests.post(url, data=data, headers=headers)
    if response.status_code == 200:
        print("STT 결과:", response.text)

        # JSON 응답 파싱
        try:
            stt_result = json.loads(response.text)
            stt_input = stt_result.get("text", "")
        except json.JSONDecodeError:
            stt_input = response.text  # JSON 파싱 실패 시 일반 텍스트로 사용

        # 텍스트 반환
        return {"text": stt_input}
    else:
        print("Error:", response.text)
        raise HTTPException(status_code=500, detail="STT 변환 중 오류가 발생했습니다.")

# 입력 모델 정의
class GenerateQuestionInput(BaseModel):
    stt_input: str

@app.post("/generate_question")
async def generate_question(
    input_data: GenerateQuestionInput,  # 입력을 JSON Body로 받음
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
):
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
        prompt = chat_prompt.format(chat_history=updated_summary, last_answer=stt_input)
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
            print(f"질문 {i+1}: {question}")

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
################################################################################

# 회원가입
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


# 로그인 (JWT 토큰 발급)
@app.post("/login", response_model=memberDto.Token)
def login_for_access_token(login_data: LoginRequest, db: Session = Depends(get_db)):
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

# 자서전 처리 함수
def process_autobiography_text(db: Session, user_id: str):
    # DB에서 사용자 정보 가져오기
    user = db.query(member.Member).filter(member.Member.login_id == user_id).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")
    
    user_name = user.name  # 사용자 이름 가져오기
    
    # 파일 경로 설정
    text_file_path = "C:/Users/Junbeom/Desktop/2024-2-CECD2-VTF-5/BackEnd/app/process_autobiography_text.txt"
    
    try:
        # 텍스트 파일 읽기
        with open(text_file_path, "r", encoding="utf-8") as file:
            autobiography_text = file.read()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"파일 읽기 오류: {str(e)}")
    
    # 템플릿 준비
    prompt = PromptTemplate(input_variables=["name", "autobiography_text"], template=autobiography_output_prompt)
    
    # 텍스트와 사용자 이름 삽입
    formatted_prompt = prompt.format(name=user_name, autobiography_text=autobiography_text)
    
    # OpenAI 모델 호출
    response = client.invoke(formatted_prompt)
    
    return response

# API 엔드포인트 수정
@app.post("/complete")
def process_autobiography(token: str = Depends(oauth2_scheme)):
    """
    완성된 자서전 텍스트를 요약하여 반환합니다. 
    사용자 이름을 가져오는 예시입니다.
    """
    try:
        # 토큰을 디코드하여 사용자 정보 추출
        decoded_token = decode_access_token(token)
        user_name = decoded_token.get("sub")  # JWT payload에서 'sub' 필드가 사용자 ID로 가정

        # 사용자 이름 확인
        if not user_name:
            raise HTTPException(status_code=400, detail="User name not found in token")

        # 사용자 이름을 이용해 추가적인 로직 처리 (예: 자서전 생성)
        return {"message": f"Autobiography processing for {user_name}"}

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing autobiography: {str(e)}")

def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        # JWT 디코딩하여 사용자의 정보를 반환
        user_data = decode_access_token(token)
        return user_data
    except Exception as e:
        raise HTTPException(status_code=401, detail="Not authenticated")


################################################################################
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
