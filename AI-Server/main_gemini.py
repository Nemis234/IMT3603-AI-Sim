from google import genai

from collections.abc import Iterator
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import StreamingResponse
from collections import defaultdict
from database import Memory
import chromadb
import asyncio

'''
# The client gets the API key from the environment variable `GEMINI_API_KEY`.
client = genai.Client()

response = client.models.generate_content(
    model="gemini-2.5-flash", contents="Tell me something interesting that happened in 1919 in one sentence"
)
print(response.text)

'''


# Roles
USER = 'user'
ASSISTANT = 'assistant'
SYSTEM = 'system'


#Gemini client
client = genai.Client()

#Establishing db client
db = chromadb.PersistentClient(path=f"./store/")

desc = '''You are John Lin. You are a pharmacy shopkeeper at the Willow
            Market and Pharmacy who loves to help people. You 
            always looking for ways to make the process
            of getting medication easier for his customers;
            You live with your wife, Mei Lin, who
            is a college professor, and son, Eddy Lin, who is
            a student studying music theory; John Lin loves
            his family very much; you know the old
            couple next-door, Sam Moore and Jennifer Moore,
            for a few years; you think Sam Moore is a
            kind and nice man; you know his neighbor,
            Yuriko Yamamoto, well; you know of his
            neighbors, Tamara Taylor and Carmen Ortiz, but
            has not met them before; you and Tom Moreno
            are colleagues at The Willows Market and Pharmacy;
            you and Tom Moreno are friends and like to
            discuss local politics together; you know
            the Moreno family somewhat well — the husband Tom
            Moreno and the wife Jane Moreno.
            
            Note: Respond to questions/queries in brief (just 1-2 sentences).'''


class Agent:
    def __init__(self, name:str, system_prompt:str=''):
        self.memory = Memory(client=db,collection_name=name)
        self._name = name
        self._system_prompt = f"{system_prompt}"
        self._create_client()
        self.memory.add(role="model", message=self._system_prompt)

    @property
    def system_prompt(self):
        return self._system_prompt
    @system_prompt.setter
    def system_prompt(self, value:str):
        self._system_prompt = f"{value}"
       
        
    

    def _create_client(self):
        pass
       
    def add_message(self, content:str, role:str='user'):
        self.memory.add(role, message=content)

    def get_memory(self, message:str):
        '''
        Doing retrieval based on query (get top n most similar db entries to query)
        '''
        history = self.memory.gemini_query(text = message)
        return history
    
    async def chat(self, participant:str,message:str, stream:bool=True):
        query_message = {'role':'user', 'parts':[{'text': message}]}
        history = self.get_memory(message) #Get most relevant entries from db closest to query

        print("Top memories:")
        for i,h in enumerate(history):
            print(f"{i+1}) {h["parts"][0]["text"]}")

        print("User is asking:", message)
        
        
        input_message = [] 
        input_message.extend(history)
        input_message.append(query_message)
        
        
        response = client.models.generate_content_stream(
                                        model="gemini-2.5-flash", contents=input_message)
        
        response_message=""
        for chunk in response:
            if chunk.candidates and chunk.candidates[0].content.parts:
                delta = chunk.candidates[0].content.parts[0].text
                response_message += delta
                if delta:
                    # Split into words (preserve spaces)
                    words = delta.split(" ")
                    for w in words:
                        if w.strip():  # skip empty tokens
                            yield w + " "
                            await asyncio.sleep(0.05)
                            

        
        #print(response_message)
        
        #Add query to memory
        memory_message = f"You were asked/told by {participant}: {message}."
        self.memory.add(role="model" ,message=memory_message)
        
        #Add response to memory
        memory_message = f"You responded to {participant}: {response_message} "
        self.memory.add(role= "model",message=memory_message)

       



# Create an agent with a system prompt
john = Agent("John", system_prompt=desc)


if __name__ == "__main__":
    while True:
        print('\nQ to quit')
        prompt = input('Enter your message: ')
        if prompt.lower() == 'q':
            break
        else:
            for response in john.chat(USER,prompt):
                pass
                #print(response, end='', flush=True)


chat_server = FastAPI()

@chat_server.post("/chat")
async def chat_endpoint(request: Request):
    """ API endpoint \n
        This endpoint allows users to send and receive messages from the chatbot.

        The response is streamed back to the client as it is generated.

        Expects a JSON payload with the following structure:

            {
                "message": "Your message here",
                "participant": "user_identifier"  # Optional, defaults to 'user'
            }

    """
    print("Received request")
    data: dict = await request.json()
    print(f"Received data: {data}")

    if not isinstance(data.get("message"), str):
        raise HTTPException(status_code=400, detail="Invalid messages format")
    
    message = data.get("message", "")
    participant = data.get("participant", USER)


    return StreamingResponse(john.chat(participant, message), media_type="text/event-stream")

