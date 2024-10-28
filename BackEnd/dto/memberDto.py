from typing import List, Optional
from pydantic import BaseModel

# 기본적인 Member 정보 스키마
class MemberBase(BaseModel):
    name: str  # 이름
    login_id: str  # 로그인 아이디
    email: Optional[str] = None  # 이메일 (Optional로 None 허용)

# 회원가입 시 필요한 스키마 (비밀번호 및 추가 정보 포함)
class MemberCreate(MemberBase):
    password: str  # 비밀번호
    birth: str  # 생년월일 (기본값 제거)
    is_male: bool  # 남성 여부
    is_married: bool  # 결혼 여부
    has_child: bool  # 자녀 유무

# 전체 Member 정보를 나타내는 스키마 (추가 필드 포함)
class Member(MemberBase):
    member_id: int  # 사용자 고유 ID
    birth: str  # 생년월일
    is_male: bool  # 남성 여부
    is_married: bool  # 결혼 여부
    has_child: bool  # 자녀 유무

    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    login_id: str
    password: str

# 여러 명의 멤버를 반환할 때 사용
class MemberList(BaseModel):
    members: List[Member]
    class Config:
        from_attributes = True

# Token 스키마
class Token(BaseModel):
    access_token: str
    token_type: str
