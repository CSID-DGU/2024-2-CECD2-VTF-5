from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from .base import Base

class Answer(Base):
    __tablename__ = "answer"

    answer_id = Column(Integer, primary_key=True, autoincrement=True)
    summary_id = Column(Integer, ForeignKey("summary.summary_id"), nullable=False)
    answer_text = Column(Text, nullable=False)           # 답변 내용
    created_at = Column(DateTime, default=datetime.utcnow)

    # 관계 설정
    summary = relationship("Summary", back_populates="answers")