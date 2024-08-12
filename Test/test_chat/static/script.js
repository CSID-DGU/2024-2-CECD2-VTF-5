document.addEventListener('DOMContentLoaded', function () {
    const chatDiv = document.getElementById('chat');
    const userInput = document.querySelector('#userInput input');
    const sendButton = document.querySelector('#userInput button');

    // 질문 출력 함수
    function getQuestion() {
        fetch('/get_question')
            .then(response => response.json())
            .then(data => {
                const questionDiv = document.createElement('div');
                questionDiv.className = 'message';
                questionDiv.innerText = '질문: ' + data.question;
                chatDiv.insertBefore(questionDiv, chatDiv.firstChild);
            });
    }

    // 답변 전송 함수
    function sendAnswer() {
        const answer = userInput.value.trim();
        if (!answer) {
            alert('답변을 입력하세요.');
            return;
        }
    
        const answerDiv = document.createElement('div');
        answerDiv.className = 'message';
        answerDiv.innerText = '답변: ' + answer;
        chatDiv.insertBefore(answerDiv, chatDiv.firstChild);
    
        fetch('/submit_answer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ answer: answer })
        })
        .then(response => response.json())
        .then(() => {
            userInput.value = '';
            getQuestion();
        });
    }

    getQuestion();
    sendButton.addEventListener('click', sendAnswer);
    userInput.addEventListener('keypress', function (event) {
        if (event.key === 'Enter') {
            sendAnswer();
        }
    });
});