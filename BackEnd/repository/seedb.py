import sqlite3

# 데이터베이스 연결
conn = sqlite3.connect('../ut/Test/test.db')

# 커서 생성
cursor = conn.cursor()

# 데이터 조회 쿼리 실행 (모든 사용자 데이터 조회)
cursor.execute("SELECT * FROM user")

# 조회한 데이터 출력
rows = cursor.fetchall()
for row in rows:
    print(row)

# 연결 닫기
conn.close()