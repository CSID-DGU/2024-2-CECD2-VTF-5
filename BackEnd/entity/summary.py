from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from .base import Base

class Summary(Base):
    __tablename__ = "summary"

    summary_id = Column(Integer, primary_key=True, autoincrement=True)
    member_id = Column(Integer, ForeignKey("member.member_id"), nullable=False)
    title = Column(String(100), nullable=False)             # 자서전 제목
    summary = Column(Text, nullable=True)                   # 자서전 요약
    recent_question = Column(Text, nullable=True)           # 마지막 질문
    recent_answer = Column(Text, nullable=True)             # 마지막 답변
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # 관계 설정
    member = relationship("Member", back_populates="summaries", lazy='joined')
    questions = relationship("Question", back_populates="summary", lazy='joined')
    answers = relationship("Answer", back_populates="summary", lazy='joined')
