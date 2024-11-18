import requests
import json
from fastapi import UploadFile, HTTPException

# 네이버 STT 로직 분리
async def stt_request(record_file: UploadFile, client_id: str, client_secret: str):
    url = "https://naveropenapi.apigw.ntruss.com/recog/v1/stt?lang=Kor"
    data = await record_file.read()
    headers = {
        "X-NCP-APIGW-API-KEY-ID": client_id,
        "X-NCP-APIGW-API-KEY": client_secret,
        "Content-Type": "application/octet-stream"
    }
    response = requests.post(url, data=data, headers=headers)

    if response.status_code == 200:
        try:
            # JSON 응답 처리
            stt_result = json.loads(response.text)
            stt_text = stt_result.get("text", "")
        except json.JSONDecodeError:
            # JSON 파싱 실패 시
            stt_text = response.text
        return {"text": stt_text}
    else:
        # 오류 처리
        raise HTTPException(status_code=500, detail="STT 변환 중 오류가 발생했습니다.")
