import ollama
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import StreamingResponse
from collections import defaultdict


model = 'gemma3'
# Roles
USER = 'user'
ASSISTANT = 'assistant'
SYSTEM = 'system'

class Memory(defaultdict):
    def __init__(self):
        super().__init__(list)

    def add_message(self, participants:frozenset, role:str, content:str):
        self[participants].append({'role': role, 'content': content})

    def get_history(self, participants:frozenset):
        return self[participants]


class Agent:
    def __init__(self, name:str, system_prompt:str=''):
        self.memory = Memory()
        self._name = name
        self._model = 'gemma3'
        self._system_prompt = f"Your name is {self._name}. {system_prompt}"
        self._create_client()

    @property
    def system_prompt(self):
        return self._system_prompt
    @system_prompt.setter
    def system_prompt(self, value:str):
        self._system_prompt = f"Your name is {self._name}. {value}"
        self._create_client()
    

    def _create_client(self):
        self.client = ollama.create(model=self._name, from_=self._model, system=self._system_prompt)

    def add_message(self, participant:str, content:str, role:str='user'):
        self.memory.add_message(frozenset({participant, self._name}), role, content)

    def get_memory(self, participant:str):
        history = self.memory.get_history(frozenset({participant, self._name}))
        return history
    
    def chat(self, participant:str,message:str, stream:bool=True):
        self.add_message(participant, message, role='user')
        history = self.get_memory(participant)

        response = ollama.chat(model=self._name,messages=history, stream=stream)

        complete_message = ''
        for line in response:
            content = line.message.content
            if content:
                complete_message += content
            yield f'data: {{ "response":"{content or ''}" }}\n\n'

        self.add_message(participant, complete_message, role='assistant')
        print(complete_message)

agent = Agent("Mary", system_prompt="You are sarcastic")


if __name__ == "__main__":
    while True:
        print('\nQ to quit')
        prompt = input('Enter your message: ')
        if prompt.lower() == 'q':
            break
        else:
            for response in agent.chat(USER,prompt):
                print(response, end='', flush=True)


chat_server = FastAPI()

@chat_server.post("/chat")
async def chat_endpoint(request: Request):
    data: dict = await request.json()
    message = data.get("message", {})

    if not isinstance(message, dict) or not "content" in message or not isinstance(message["content"], str):
        raise HTTPException(status_code=400, detail="Invalid messages format")
    
    content = message.get("content", "")
    participant = data.get("participant", USER)

    return StreamingResponse(agent.chat(participant, content), media_type="text/event-stream")