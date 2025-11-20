from google import genai
from google.genai import types
from collections.abc import Iterator
from database import Memory
import chromadb
import asyncio
from pydantic import BaseModel, Field


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


#Base model for action response
class ActionDetails(BaseModel):
    action : str = Field(description="The chosen action")
    duration: int = Field(description="Duration in minutes")
    visiting: str = Field(description="Name of the location to visit, if action is visit")


class Agent:
    def __init__(self, name:str, system_prompt:str='', slot='0'):
        self.memory = Memory(collection_name=name, slot=slot)
        self._name = name
        self.action_prompt = system_prompt
        self.chat_prompt = system_prompt
        self.reflection_prompt = system_prompt
        
        self.action_model = "gemini-2.5-flash-lite"
        self.chat_model = "gemini-2.5-flash-lite"
        self.reflection_model = "gemini-2.0-flash"
        self.memory_count = 50
        self._create_client()
        #self.memory.add(role="model", message=self._system_prompt)

    @property
    def action_prompt(self):
        note = f"""\n\nAlways respond in the way the user is requesting."""
        return self._action_prompt + note
    @action_prompt.setter
    def action_prompt(self, value:str):
        self._action_prompt = f"{value}"
    
    @property
    def chat_prompt(self):
        note = f"""\n\nYou should always respond in character as {self._name}. Follow these guidelines strictly:
        Respond to questions and queries in brief (just 1-2 sentences).
        Never mention that you are an AI model. Never respond with anything related to being an AI model.
        Absolutely never respond with with anything along the lines of "At [Day/Time] you responded to [participant]".
        Absolutely never respond with with anything along the lines of "You responded to [participant] on [Day/Time]".
        """
        return self._chat_prompt + note
    @chat_prompt.setter
    def chat_prompt(self, value:str):
        self._chat_prompt = f"{value}"
       

    def _create_client(self):
        pass
    

    def generate_content_stream(self, input_message: list[dict]) -> Iterator[types.GenerateContentResponse]:
        response = client.models.generate_content_stream(
                            model=self.chat_model,
                            contents=input_message,
                            config=types.GenerateContentConfig(
                                system_instruction=self.chat_prompt)) #Generating responses based on system prompts
        return response

    def generate_content(self, input_message: list[dict]) -> types.GenerateContentResponse:
        response = client.models.generate_content(
                            model=self.action_model,
                            contents=input_message,
                            config=types.GenerateContentConfig(
                                response_mime_type="application/json",
                                response_json_schema=ActionDetails.model_json_schema(),
                                system_instruction=self.action_prompt)) #Generating responses based on system prompts
        return response
    
    def generate_reflection(self, input_message: list[dict]) -> types.GenerateContentResponse:
        response = client.models.generate_content(
                            model=self.reflection_model,
                            contents=input_message,
                            config=types.GenerateContentConfig(
                                system_instruction=self.reflection_prompt)) #Generating responses based on system prompts
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
        new_message = f"{participant} says: {message}"
        query_message = {'role':"user", 'parts':[{'text': new_message}]}
        history = self.get_memory(message) #Get most relevant entries from db closest to query

        print("Top memories:")
        for i,h in enumerate(history):
            print(f"{i+1}) {h["parts"][0]["text"]}")
            pass

        print(new_message)

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

        banned_prefixes = [f"You replied to {participant} on {time_stamp}:",
                        f"You replied to {participant}:",
                        f"You responded to {participant} on {time_stamp}:",
                        f"You responded to {participant}:",
                        f"You responded:",
                        f"At {time_stamp}, you responded to {participant}:",
                        f"At {time_stamp}, you replied to {participant}:",
                        f"I replied to {participant} on {time_stamp}:",
                        f"I replied to {participant}:",
                        f"I responded to {participant} on {time_stamp}:",
                        f"I responded to {participant}:",
                        f"I told {participant} on {time_stamp}:",
                        f"I told {participant}:",
                        f"{self._name} responding:",
                        f"{self._name} replying:",
                        f"on {time_stamp}:"
                        ]
        print()
        print(f"Raw response: ", response_message)

        for prefix in banned_prefixes:
            response_message = response_message.replace(prefix, "",1)

        print()
        print("Cleaned response: ", response_message)

        #Add query to memory
        if save_query:
            memory_message = f"On {time_stamp}, you were asked/told by {participant}: {message}."
            self.memory.add(role="user" ,message=memory_message,time_stamp=time_stamp)
            
        #Add response to memory
        if save_response:
            memory_message = f"On {time_stamp}, you responded to {participant}: {response_message} "
            self.memory.add(role= "model",message=memory_message,time_stamp=time_stamp)
    

        
    
    async def start_ai_chat(self,participant:str,message:str,time_stamp):
        '''
        Wrapper function to start chat with agent
        '''

        response_message=""
        async for chunk in self.chat(USER,message,time_stamp,False, False):
            response_message += chunk
            yield chunk


        memory_message = f"On {time_stamp}, you started a conversation with {participant} by saying: {response_message} "
        self.memory.add(role= "model",message=memory_message,time_stamp=time_stamp)
    
    
    #Standard function to get a response from an LLM from on a message and adds only response to memory
    async def act(self,agent_details:dict):
        
        action_list = agent_details.get("action_list", "")
        time_stamp = agent_details.get("time","")
        location = agent_details.get("location","") #Gets current location
        visit_list = dict(agent_details.get("visit_list",{})).keys() #Dict of other agents that can be visited
       
        
        #Specifying output format and adding it to message (Message would be only plausible action list)
        action_prompt = f""" Assign values to keys "action", "duration", and "visiting" based on the following prompt: This is your current location: {location}. Pick an action strictly from this array [{', '.join(action_list)}] that you feel like should be done now. Decide a suitable duration it will take for you to perform the action. If the decided action is "visit", strictly assign the key "visiting" to the name of a location strictly from this list: [{', '.join(visit_list)}] which you feel like you should visit. Otherwise, assign "visiting" to "". Ensure duration is a single number (in minutes)
                            """
        
        
        query_message = {'role':'user', 'parts':[{'text': action_prompt}]}
        history = self.get_memory(action_prompt) #Get most relevant entries from db closest to query (message)
        input_message = [] 
        input_message.extend(history)
        input_message.append(query_message)

        response = self.generate_content(input_message)
        
        action_dict = dict(ActionDetails.model_validate_json(response.text)) #Dict {action: , duration: , visiting: }

       
        print(f"prompt for {self._name}:{action_prompt}")
        print("Top memories relevant to action:")
        for i,h in enumerate(history):
            print(f"{i+1}) {h["parts"][0]["text"]}")
        print(f"Action taken: {action_dict["action"]} for {action_dict["duration"]} minutes. Visiting: {action_dict["visiting"]}")

        if action_dict["action"]=="visit": #If action is "visit", provide custom action message
            action_message = f"On {time_stamp}, you visited {action_dict["visiting"]}"
        else: #Otherwise
            action_message = f"On {time_stamp}, you performed the following action: {action_dict["action"]}"
        
        self.memory.add(role="model",message=action_message,time_stamp=time_stamp) #Noting action to memory
        
        return action_dict

    async def reflect(self):
        reflection_prompt = f""" Reflect on your relevant memories, including chats, actions, prior reflections etc. Provide deep insights and summarize key learnings strictly in 2-3 sentences."""

        query_message = {'role':'user', 'parts':[{'text': reflection_prompt}]}
        history = self.get_memory(reflection_prompt) #Get most relevant entries from db closest to query (message)
        input_message = [] 
        input_message.extend(history)
        input_message.append(query_message)

        reflection = self.generate_reflection(input_message)
        print(f"{self._name} is reflecting...")
        print(f"Reflection: {reflection.text}")
        
        self.memory.add(role="model",message=reflection.text) #Noting reflection to memory