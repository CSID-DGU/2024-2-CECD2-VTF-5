from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from .base import Base


class Question(Base):
    __tablename__ = "question"

    question_id = Column(Integer, primary_key=True, autoincrement=True)
    summary_id = Column(Integer, ForeignKey("summary.summary_id"), nullable=False)
    question_text = Column(Text, nullable=False)         # 질문 내용
    question_type = Column(String(50), nullable=True)     # 질문 유형 (경험, 취미 등)
    created_at = Column(DateTime, default=datetime.utcnow)

    # 관계 설정
    summary = relationship("Summary", back_populates="questions")

