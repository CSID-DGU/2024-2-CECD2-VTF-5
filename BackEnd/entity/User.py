from sqlalchemy import Column, String, Boolean, Integer
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = "user"

    사용자고유ID = Column(Integer, primary_key=True, index=True, autoincrement=True)
    이름 = Column(String, nullable=False)
    아이디 = Column(String, unique=True, nullable=False)
    비밀번호 = Column(String, nullable=False)
    이메일 = Column(String, unique=True, nullable=False)
    생년월일 = Column(String, nullable=False)
    성별_남성여부 = Column(Boolean, nullable=False)
    결혼여부 = Column(Boolean, nullable=False)
    자녀유무 = Column(Boolean, nullable=False)