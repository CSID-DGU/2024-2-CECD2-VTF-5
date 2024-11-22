# FastAPI 관련
from datetime import datetime
from fastapi import HTTPException


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