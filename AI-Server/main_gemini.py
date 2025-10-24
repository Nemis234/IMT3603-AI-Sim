from google import genai
from google.genai import types
from collections.abc import Iterator
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import StreamingResponse,Response,JSONResponse
from collections import defaultdict
from database import Memory
import chromadb
import asyncio
from agent_map import AGENT_DESC


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
SYSTEM = 'model'


#Gemini client
client = genai.Client()

#Establishing db client
db = chromadb.PersistentClient(path=f"./store/")


class Agent:
    def __init__(self, name:str, system_prompt:str=''):
        self.memory = Memory(client=db,collection_name=name)
        self._name = name
        self._system_prompt = f"{system_prompt}"
        self._create_client()
        #self.memory.add(role="model", message=self._system_prompt)

    @property
    def system_prompt(self):
        return self._system_prompt
    @system_prompt.setter
    def system_prompt(self, value:str):
        self._system_prompt = f"{value}"
       

    def _create_client(self):
        pass
       

    def get_memory(self, message:str):
        '''
        Doing retrieval based on query (get top n most similar db entries to query)
        '''
        history = self.memory.gemini_query(text = message)
        return history
    
    def save_action_memory(self,action,time_stamp):
        '''
            Func to save memories associated with actions
        '''

        action_message = f"You previously performed the following action: {action} at time {time_stamp}"
        self.memory.add(role="model",message=action_message,time_stamp=time_stamp) #Noting action to memory


    async def chat(self, participant:str,message:str,time_stamp):
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
                                        model="gemini-2.5-flash", 
                                        contents=input_message,
                                         config=types.GenerateContentConfig(
                                                system_instruction=self._system_prompt)) #Generating responses based on system prompts
        
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
        memory_message = f"At {time_stamp}, you were asked/told by {participant}: {message}."
        self.memory.add(role="model" ,message=memory_message,time_stamp=time_stamp)
        
        #Add response to memory
        memory_message = f"You responded to {participant} at {time_stamp}: {response_message} "
        self.memory.add(role= "model",message=memory_message,time_stamp=time_stamp)
    
    
    #Standard function to get a response from an LLM from on a message and adds only response to memory
    async def act(self,agent_details:dict):
        
        action_list = agent_details.get("action_list", "")
        time_stamp = agent_details.get("time","")
        location = agent_details.get("location","") #Gets current location
        
        #Specifying output format and adding it to message (Message would be only plausible action list)
        action_prompt = f""" This is your current location {location}. Pick an action from this array {action_list}  that you feel like should be done now. Decide a suitable duration it will take for you to perform the action and strictly output the following: action,duration.
                            Ensure duration is a single number (in minutes)
                            """
        
        
        query_message = {'role':'user', 'parts':[{'text': action_prompt}]}
        history = self.get_memory(action_prompt) #Get most relevant entries from db closest to query (message)
        input_message = [] 
        input_message.extend(history)
        input_message.append(query_message)

        response = client.models.generate_content(
                                        model="gemini-2.5-flash", 
                                        contents=input_message,
                                         config=types.GenerateContentConfig(
                                                system_instruction=self._system_prompt)) #Generating responses based on system prompts
        

        action_dict = {"action": response.text.split(',')[0],"duration": response.text.split(',')[1]} #Dict {action: , duration: }
        
        print("Top memories relevant to action:")
        for i,h in enumerate(history):
            print(f"{i+1}) {h["parts"][0]["text"]}")
        print(f"Action taken: {action_dict["action"]} for {action_dict["duration"]} minutes")

        
        action_message = f"You decided to perform the following action: {action_dict["action"]} at time {time_stamp}"
        self.memory.add(role="model",message=action_message,time_stamp=time_stamp) #Noting action to memory
        
        return action_dict

    

#Store map of agents to its respective object
agent_obj_map = { "John": Agent("John",system_prompt=AGENT_DESC["John"]),
                  "Mei": Agent("Mei",system_prompt=AGENT_DESC["Mei"]),
                  }      

chat_server = FastAPI()


@chat_server.get("/agents")
async def get_agents():
    """ API endpoint to retrieve the list of available agents"""
    return {"agents": list(agent_obj_map.keys())}

@chat_server.post("/chat")
async def chat_endpoint(request: Request):
    """ API endpoint for chatting with an agent\n
        This endpoint allows users to send and receive messages from the chatbot.
        The response is streamed back to the client as it is generated.

        Expects a JSON payload with the following structure:

            {
                "agent": "AgentName",
                "message": "Your message here",
                "time": "timestamp",
                "participant": "user_identifier"  # Optional, defaults to 'user'
            }

    """
    print("Received request")
    data: dict = await request.json()
    print(f"Received data: {data}")

    if not isinstance(data.get("message"), str) or not isinstance(data.get("agent"), str):
        raise HTTPException(status_code=400, detail="Invalid messages format")
    
    agent = data.get("agent","")
    message = data.get("message", "")
    time_stamp = data.get("time","")
    participant = data.get("participant", USER)


    return StreamingResponse(agent_obj_map[agent].chat(participant, message,time_stamp), media_type="text/event-stream")


@chat_server.post("/action")
async def action_endpoint(request: Request):
    """ API endpoint for handling actions\n

    This endpoint should receive a request from Godot which is something like:
    Pick an action from this array that you feel like should be done now {[action_array]}. Ouput only the action

    This sends back the response , which is the resultant action, back to Godot and the repsonse is saved in memory. 
        

    """
    print("Received request")
    data: dict = await request.json()
    print(f"Received data: {data}")

    if not isinstance(data.get("action_list"), str):
        raise HTTPException(status_code=400, detail="Invalid messages format")
    
    agent = data.get("agent","") #Get the agent name 
    

    action_dict = await agent_obj_map[agent].act(data) #Wait for response
    #print(action_dict)
    return JSONResponse(action_dict)
