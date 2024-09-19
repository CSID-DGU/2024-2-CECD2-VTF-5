import os
import sqlite3
from dotenv import load_dotenv
from openai import OpenAI
from langchain.prompts import PromptTemplate

# .env 파일에서 환경 변수 로드
load_dotenv()

# 환경 변수에서 키 가져오기
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# OpenAI 클라이언트 초기화
client = OpenAI(api_key=OPENAI_API_KEY)

# SQLite 데이터베이스 연결
conn = sqlite3.connect('chat_history.db')
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


def get_chat_history():
    """
    DB에서 모든 채팅 기록을 가져옴
    """
    cursor.execute("SELECT role, content FROM chat_history")
    return cursor.fetchall()


def get_user_chat_history():
    """
    DB에서 사용자가 입력한 채팅 기록만 가져옴 (role이 'user'인 것만)
    """
    cursor.execute("SELECT content FROM chat_history WHERE role='user'")
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
    chat_history_text = "\n".join([f"{role}: {content}" for role, content in chat_history])

    response = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": prompt.format(chat_history=chat_history_text, last_answer=last_answer)},
            {"role": "user", "content": "다음 질문을 생성해주세요."}
        ],
        temperature=0.7
    )
    return response.choices[0].message.content.strip()


def generate_autobiography(user_content):
    """
    사용자가 입력한 대화 내용을 바탕으로 자서전을 생성
    """
    user_content_text = "\n".join([content for (content,) in user_content])

    prompt_text = f"""당신은 AI 자서전 작성을 돕는 assistant입니다. 사용자가 제공한 아래 내용을 바탕으로 자서전의 일부를 작성해주세요.

    사용자가 제공한 내용:
    {user_content_text}

    자서전 형식으로 정리된 내용:
    """

    response = client.chat.completions.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": prompt_text},
            {"role": "user", "content": "자서전으로 정리해주세요."}
        ],
        temperature=0.7
    )
    return response.choices[0].message.content.strip()


if __name__ == "__main__":
    print("AI 구술 자서전 작성을 위한 질문 생성기입니다.")
    print("종료하려면 'q'를 입력하세요.")
    print("대화 내용을 보려면 'h'를 입력하세요.")

    question_count = 0
    last_answer = ""

    while True:
        if question_count == 0:
            question = "자신의 어린 시절에 대해 간단히 말씀해 주시겠어요?"
        else:
            chat_history = get_chat_history()
            question = generate_question(chat_history, last_answer)

        print(f"\n질문: {question}")
        add_to_chat_history("assistant", question)

        user_input = input("답변: ")
        if user_input.lower() == "q":
            break
        elif user_input.lower() == "h":
            print("\n대화 내용:")
            for role, content in get_chat_history():
                print(f"{role}: {content}")
            print("\n")
            continue

        add_to_chat_history("user", user_input)
        last_answer = user_input
        question_count += 1

    # 사용자 대화 기록을 가져옴 (DB를 닫기 전에)
    user_chat_history = get_user_chat_history()

    # 데이터베이스 연결 종료
    conn.close()
    print("\n프로그램을 종료합니다. 감사합니다.")

    # 사용자의 대화 기록을 바탕으로 자서전 생성
    autobiography = generate_autobiography(user_chat_history)

    # 자서전 내용을 파일로 저장
    with open('autobiography.txt', 'w', encoding='utf-8') as f:
        f.write(autobiography)

    print("자서전 파일이 생성되었습니다.")
