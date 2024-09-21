from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

questions = [
    "6살 때 어떤 자전거를 타셨나요?",
    "어떤 이유로 파란색 자전거를 사셨나요?",
    "유년시절 어느 동네에서 자라셨나요?",
    "유년시절 가장 친했던 친구와는 어떤 추억을 가지고 계신가요?",
    "인생에서 가장 행복했던 순간은 언제인가요?"
]

current_question_index = 0

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    global current_question_index
    current_question_index = 0
    return templates.TemplateResponse("testChat.html", {"request": request})

@app.get("/get_question")
async def get_question():
    global current_question_index
    if current_question_index < len(questions):
        question = questions[current_question_index]
        return {"question": question}
    else:
        return {"question": "질문이 끝났습니다. 수고하셨습니다!"}
    
@app.post("/submit_answer")
async def submit_answer(request: Request):
    global current_question_index
    data = await request.json()
    answer = data.get("answer")

    current_question_index +=1

    return JSONResponse(content={"status": "success"})
