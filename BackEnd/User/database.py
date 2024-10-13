from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# PostgreSQL 데이터베이스 URL
DATABASE_URL = os.getenv("DATABASE_URL")

# SQLAlchemy 엔진 설정
engine = create_engine(DATABASE_URL)

# 세션 설정
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 베이스 클래스 설정
Base = declarative_base()

# 데이터베이스 세션을 제공하는 의존성 함수
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()