from google import genai
from google.genai import types
from collections.abc import Iterator
from database import Memory
import chromadb
import asyncio


'''
# The client gets the API key from the environment variable `GEMINI_API_KEY`.
client = genai.Client()

response = client.models.generate_content(
    model="gemini-2.5-flash", contents="Tell me something interesting that happened in 1919 in one sentence"
)

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
        self.system_prompt = system_prompt
        self.action_model = "gemini-2.5-flash"
        self.chat_model = "gemini-2.0-flash-lite"
        self.memory_count = 25
        self._create_client()
        #self.memory.add(role="model", message=self._system_prompt)

    @property
    def system_prompt(self):
        note = "\n\nNote: Respond to questions/queries in brief (just 1-2 sentences)."
        return self._system_prompt + note
    @system_prompt.setter
    def system_prompt(self, value:str):
        self._system_prompt = f"{value}"
       

    def _create_client(self):
        pass
    

    def generate_content_stream(self, input_message: list[dict]) -> Iterator[types.GenerateContentResponse]:
        response = client.models.generate_content_stream(
                            model=self.chat_model,
                            contents=input_message,
                            config=types.GenerateContentConfig(
                                system_instruction=self.system_prompt)) #Generating responses based on system prompts
        return response

    def generate_content(self, input_message: list[dict]) -> types.GenerateContentResponse:
        response = client.models.generate_content(
                            model=self.action_model,
                            contents=input_message,
                            config=types.GenerateContentConfig(
                                system_instruction=self.system_prompt)) #Generating responses based on system prompts
        return response


    def get_memory(self, message:str):
        '''
        Doing retrieval based on query (get top n most similar db entries to query)
        '''
        history = self.memory.gemini_query(text = message, n=self.memory_count)
        return history
    
    def save_action_memory(self,action,time_stamp):
        '''
            Func to save memories associated with actions
        '''

        action_message = f"You previously performed the following action: {action} at time {time_stamp}"
        self.memory.add(role="model",message=action_message,time_stamp=time_stamp) #Noting action to memory


    async def chat(self, participant:str,message:str,time_stamp,save_query:bool=True,save_response:bool=True):
        query_message = {'role':"user", 'parts':[{'text': message}]}
        history = self.get_memory(message) #Get most relevant entries from db closest to query

        print("Top memories:")
        for i,h in enumerate(history):
            print(f"{i+1}) {h["parts"][0]["text"]}")

        print("User is asking:", message)
        
        
        input_message = [] 
        input_message.extend(history)
        input_message.append(query_message)

        response = self.generate_content_stream(input_message)

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
                
        #Add query to memory
        if save_query:
            memory_message = f"On {time_stamp}, you were asked/told by {participant}: {message}."
            self.memory.add(role="user" ,message=memory_message,time_stamp=time_stamp)
            
        #Add response to memory
        if save_response:
            memory_message = f"You responded to {participant} on {time_stamp}: {response_message} "
            self.memory.add(role= "model",message=memory_message,time_stamp=time_stamp)
    

        
    
    async def start_ai_chat(self,participant:str,message:str,time_stamp):
        '''
        Wrapper function to start chat with agent
        '''

        response_message=""
        async for chunk in self.chat(participant,message,time_stamp,False, False):
            response_message += chunk
            yield chunk
        
        
        memory_message = f"On {time_stamp}, you started a conversation with {participant} by saying: {response_message} "
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

        response = self.generate_content(input_message)

        action_dict = {"action": response.text.split(',')[0],"duration": response.text.split(',')[1]} #Dict {action: , duration: }
        
        print("Top memories relevant to action:")
        for i,h in enumerate(history):
            print(f"{i+1}) {h["parts"][0]["text"]}")
        print(f"Action taken: {action_dict["action"]} for {action_dict["duration"]} minutes")


        action_message = f"On {time_stamp}, you performed the following action: {action_dict["action"]}"
        self.memory.add(role="model",message=action_message,time_stamp=time_stamp) #Noting action to memory
        
        return action_dict

        