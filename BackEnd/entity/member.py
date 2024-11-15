from sqlalchemy import Column, String, Boolean, Integer, Date
from sqlalchemy.orm import relationship
from .base import Base

class Member(Base):
    __tablename__ = "member"

    member_id = Column(Integer, primary_key=True, index=True, autoincrement=True) # 고유 ID
    name = Column(String, nullable=False) # 이름
    login_id = Column(String, unique=True, nullable=False) # 로그인 아이디
    password = Column(String, nullable=False) # 로그인 패스워드
    email = Column(String, unique=True, nullable=False) # 이메일
    birth = Column(String, nullable=False) # 생년월일
    is_male = Column(Boolean, nullable=False) # 남성인지 (1남성, 0여성)
    is_married = Column(Boolean, nullable=False) # 결혼했는지 (1결혼, 0미혼)
    has_child = Column(Boolean, nullable=False) # 아이있는지 (1자녀있음, 0자녀없음)

    summary = Column(String, nullable=True) # 서머리 추가

    # Relationships
    summaries = relationship("Summary", back_populates="member", lazy='joined')
