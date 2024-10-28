from sqlalchemy.orm import Session
from BackEnd.entity import member
from BackEnd.dto import memberDto


# 유저 목록 가져오기
def get_users(db: Session, skip: int = 0, limit: int = 10):
    return db.query(member.Member).offset(skip).limit(limit).all()

# 유저 생성
def create_user(db: Session, member_data: memberDto.MemberCreate):
    db_user = member.Member(
        name=member_data.name,
        login_id=member_data.login_id,
        password=member_data.password,
        email=member_data.email,
        birth=member_data.birth,  # 기본 값 사용 시 그대로 입력
        is_male=member_data.is_male,
        is_married=member_data.is_married,
        has_child=member_data.has_child
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
