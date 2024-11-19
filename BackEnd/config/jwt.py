import os
from typing import Optional

# JWT 관련
import jwt as pyjwt  # pyjwt 패키지를 사용하고 있음. jwt말고, pyjwt 써야함. 충돌 가능해서
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext

# FastAPI 관련
from fastapi import FastAPI, HTTPException
from datetime import datetime, timedelta

# JWT 설정
SECRET_KEY = os.getenv("SECRET_KEY", "your_secret_key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# 비밀번호 관련
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")  # 비밀번호 해싱을 위한 설정

def get_password_hash(password: str) -> str:
    """
    JWT : 비밀번호 해싱 함수
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    JWT : 비밀번호 검증 함수
    """
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """
    JWT : 토큰 생성하기
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return pyjwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def decode_access_token(token: str):
    """
    JWT : 토큰 디코드 하기
    """
    try:
        payload = pyjwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except pyjwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except pyjwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")