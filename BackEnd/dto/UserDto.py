from typing import List, Optional
from pydantic import BaseModel

# 기본적인 User 정보 스키마
class UserBase(BaseModel):
    이름: str  # name
    아이디: str  # member_id
    이메일: Optional[str] = None  # email (Optional로 None 허용)

# User 생성 시 필요한 스키마 (비밀번호 추가, 선택적 필드 포함)
class UserCreate(UserBase):
    비밀번호: str  # password
    생년월일: Optional[str] = "2000-01-01"  # birth (기본값 추가)
    성별_남성여부: Optional[bool] = True  # is_male (기본값 추가)
    결혼여부: Optional[bool] = False  # is_married (기본값 추가)
    자녀유무: Optional[bool] = False  # has_child (기본값 추가)

# 전체 User 정보를 나타내는 스키마 (id와 같은 추가 정보 포함)
class User(UserBase):
    사용자고유ID: int  # user_id
    생년월일: str  # birth
    성별_남성여부: bool  # is_male
    결혼여부: bool  # is_married
    자녀유무: bool  # has_child

    class Config:
        from_attributes  = True

# 여러 명의 유저를 반환할 때 사용
class UserList(BaseModel):
    users: List[User]

    class Config:
        from_attributes  = True

# Token 스키마
class Token(BaseModel):
    access_token: str
    token_type: str