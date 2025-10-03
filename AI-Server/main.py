import ollama
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import StreamingResponse
from collections import defaultdict


class Memory(defaultdict):
    def __init__(self):
        super().__init__(list)

    def add_message(self, participants:frozenset, role:str, content:str):
        self[participants].append({'role': role, 'content': content})

    def get_history(self, participants:frozenset):
        return self[participants]


model = 'gemma3'
messages = []
# Roles
USER = 'user'
ASSISTANT = 'assistant'

memories = Memory()

def chat(message, role=USER, respondant=ASSISTANT):
    key = frozenset({role, respondant}) # Unique key for the conversation, independent of order

    memories.add_message(key, USER, message)
    print(memories.get_history(key))

    response = ollama.chat(model=model, messages=memories.get_history(key), stream=True)

    complete_message = ''
    for line in response:
        content = line.message.content
        if content:
          complete_message += content

        yield f'data: {{ "response":"{content or ''}" }}\n\n'

    memories.add_message(key, ASSISTANT, complete_message)
    print(complete_message)


if __name__ == "__main__":
    while True:
        print('\nQ to quit')
        prompt = input('Enter your message: ')
        if prompt.lower() == 'q':
            break
        else:
            for response in chat(prompt):
                print(response, end='', flush=True)


chat_server = FastAPI()

@chat_server.post("/chat")
async def chat_endpoint(request: Request):
    data: dict = await request.json()
    message = data.get("message", {})

    if not isinstance(message, dict) or not "content" in message or not isinstance(message["content"], str):
        raise HTTPException(status_code=400, detail="Invalid messages format")
    
    content = message.get("content", "")
    role = message.get("role", USER)
    respondant = data.get("respondant", ASSISTANT)

    return StreamingResponse(chat(content, role, respondant), media_type="text/event-stream")