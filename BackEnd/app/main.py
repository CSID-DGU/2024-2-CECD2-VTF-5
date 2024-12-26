import asyncio
from dotenv import load_dotenv
from pydantic import BaseModel

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

# html 템플릿 관련 (안쓰니까 일단 주석처리)
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse

# py 파일들 불러오기
from ..config.jwt import *
from ..config.test_database import SessionLocal
from ..dto.memberDto import LoginRequest
from ..entity import member
from ..dto import memberDto
from ..service import tts, stt
from ..prompt import complete_prompt, member_prompt, another_question_prompt

# 환경 변수 로드
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
load_dotenv(dotenv_path=dotenv_path)

# OpenAI API 키를 환경 변수에서 가져오기
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Naver STT key
client_id = os.getenv("YOUR_CLIENT_ID")
client_secret = os.getenv("YOUR_CLIENT_SECRET")

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
# 다른 주제의 질문을 위한 프롬프트 템플릿
another_prompt_template = PromptTemplate(input_variables=["chat_history", "last_answer"], template= another_question_prompt.another_prompt)
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


"""
여기 함수는 유사/다른 부분만 차이가 있으므로 추후 최적화 해야함. 2024.12.26.
"""
@app.post("/generate_another_question")
async def generate_another_question(
        input_data: SpeechModel,
        db: Session = Depends(get_db),
        token: str = Depends(oauth2_scheme)
):
    """
    gpt에게 다른 주제의 질문 생성 요청
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

        # 3. 누적된 요약을 바탕으로 다른 주제의 질문 생성
        prompt = another_prompt_template.format(chat_history=updated_summary, last_answer=stt_input)
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
        print(f"General error in generating another question from input: {str(e)}")
        raise HTTPException(status_code=500, detail="다른 주제의 질문 생성 중 오류가 발생했습니다.")


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
def process_autobiography_with_length(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """
    완성된 자서전 텍스트를 요약하여 반환하고 content와 글자 수를 함께 반환
    """
    try:
        # 기존 처리 내용
        decoded_token = decode_access_token(token)
        user_id = decoded_token.get("sub")

        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token: User ID not found.")

        user = db.query(member.Member).filter(member.Member.login_id == user_id).first()

        if not user:
            raise HTTPException(status_code=404, detail="User not found.")

        user_name = user.name
        user_summary = user.summary
        user_birth = user.birth

        user_age = calculate_age(user_birth)

        if not user_summary:
            raise HTTPException(status_code=400, detail="User has not provided a summary.")

        formatted_prompt = autobiography_prompt.format(
            name=user_name,
            age=user_age,
            responses=user_summary
        )

        # OpenAI API 호출
        response = client.invoke(formatted_prompt)

        # response.content로 content 필드 접근
        content = response.content if hasattr(response, 'content') else ""
        content_length = len(content)

        # content와 content_length 반환
        return {
            "content": content,
            "content_length": content_length
        }

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing autobiography: {str(e)}")

@app.get("/mypage", response_model=dict)
def get_user_mypage(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """
    유저의 마이페이지
    사용자 인적사항과 요약(summary)을 포함
    """
    try:
        # 토큰에서 사용자 정보 추출
        decoded_token = decode_access_token(token)
        user_id = decoded_token.get("sub")

        if not user_id:
            raise HTTPException(status_code=401, detail="유효하지 않은 토큰입니다.")

        # 사용자 정보 조회
        user = db.query(member.Member).filter(member.Member.login_id == user_id).first()

        if not user:
            raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

        # 사용자 정보 구성
        user_info = {
            "name": user.name,
            "email": user.email,
            "birth": user.birth,
            "is_male": user.is_male,
            "is_married": user.is_married,
            "has_child": user.has_child,
            "summary": user.summary or "요약 정보가 없습니다."
        }

        return user_info

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail="마이페이지 데이터를 가져오는 중 오류가 발생했습니다.")
    
@app.post("/generate_new_topic_question")
async def generate_new_topic_question(input_data: SpeechModel, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    """
    GPT에게 사용자의 정보를 기반으로 맞춤화된 질문을 생성 요청
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

        # 1. 사용자 정보 가져오기 (DB에서 'name', 'birth', 'job', 'interests' 필드를 가져옵니다)
        user = db.query(member.Member).filter(member.Member.login_id == user_id).first()

        if not user:
            raise HTTPException(status_code=404, detail="User not found.")

        # 사용자 정보
        user_name = user.name
        user_birth = user.birth
        
        # 나이 계산
        user_age = calculate_age(user_birth)

        # 2. 사용자 맞춤형 질문 생성 프롬프트
        new_topic_prompt = f"""
        사용자 정보:
        - 나이: {user_age}
        - 생년월일: {user_birth}

        사용자의 정보에 맞는, 개별화된 3개의 질문을 생성해주세요. 이전에 답했던 질문과는 다른 주제를 다뤄야합니다.
        질문은 사용자의 나이, 생년월일을 바탕으로 시대적 배경과 관련된 주제로 다뤄야 하며, 사회적 변화나 현재의 삶을 반영해야 합니다.
        질문은 친절하고 따뜻한 어조로 작성되어야 하며, 사용자가 자연스럽게 자신의 이야기를 풀어낼 수 있도록 유도해야 합니다. 또한 어려운 단어 및 최신 탄생한 단어는 가급적 사용을 피해야합니다.
        각 질문은 다음 요소를 다룰 수 있습니다:

        1. **세대적 차이**: 사용자가 경험한 시대적 변화나 특정 세대에서 나타나는 특성에 대한 질문.
        2. **기술 발전**: 사용자가 경험한 주요 기술 발전(인터넷, 스마트폰 등)과 그 변화에 대한 질문.
        3. **사회적 변화**: 사용자가 경험한 사회적, 정치적 사건들(예: 경제 위기, 정치적 변화)과 그 사건들이 개인의 삶에 미친 영향.
        4. **문화적 영향**: 사용자가 자라온 환경에서의 문화적 특성(음악, 영화, 패션 등)이 오늘날까지 영향을 미친 부분에 대한 질문.
        5. **현재의 삶과 미래**: 현재의 삶에 대해 어떻게 느끼는지, 앞으로의 변화에 대한 예측과 희망에 대한 질문.
        6. **사회적 연대**: 사용자가 겪은 사회적 연대나 협력의 경험, 그리고 이를 통한 교훈에 대한 질문.

        이 요소들을 고려하여 사용자가 자신의 삶과 시대적 배경에 대해 더욱 깊이 성찰할 수 있도록 도와주는 질문을 만들어주세요.
        

        생성된 질문:
        """

        # 새로운 질문 생성
        response = client.invoke(new_topic_prompt)

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

        # 결과 반환
        return {
            "new_topic_questions": questions
        }

    except Exception as e:
        print(f"General error in generating new_topic question: {str(e)}")
        raise HTTPException(status_code=500, detail="질문 생성 중 오류가 발생했습니다.")