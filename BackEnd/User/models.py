from sqlalchemy import Column, String, Boolean, Integer
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = "user"

    사용자고유ID = Column(Integer, primary_key=True, index=True, autoincrement=True)  # user_id
    이름 = Column(String, nullable=False)  # name
    아이디 = Column(String, unique=True, nullable=False)  # member_id
    비밀번호 = Column(String, nullable=False)  # password
    이메일 = Column(String, unique=True, nullable=False)  # email
    생년월일 = Column(String, nullable=False)  # birth (LocalDate는 String으로 간단히 사용)
    성별_남성여부 = Column(Boolean, nullable=False)  # is_male
    결혼여부 = Column(Boolean, nullable=False)  # is_married
    자녀유무 = Column(Boolean, nullable=False)  # has_child