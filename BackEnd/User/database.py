from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# 데이터베이스 URL 설정 (PostgreSQL 예시)
SQLALCHEMY_DATABASE_URL = "postgresql://{username}:{password}@localhost:5432/{dbname}"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependency - 요청 시마다 새로운 DB 세션을 생성하고, 완료되면 자동으로 세션을 종료
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()