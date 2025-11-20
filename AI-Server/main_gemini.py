from google import genai
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import StreamingResponse,Response,JSONResponse
import chromadb
from agent_map import AGENT_DESC
from gemini_agent import Agent
from database import Memory
import asyncio


# Roles
USER = 'user'
ASSISTANT = 'assistant'
SYSTEM = 'model'


chat_server = FastAPI()


#To Store map of agents to its respective object (Initialized after obtaining save slot)
agent_obj_map = None

def assign_slot(slot:str):
    global agent_obj_map
    agent_obj_map = { "John": Agent("John", system_prompt=AGENT_DESC["John"], slot = slot),
                    "Mei": Agent("Mei", system_prompt=AGENT_DESC["Mei"], slot = slot),
                    }      


#Assign proper db to corresponding save
@chat_server.post("/get_save_slot")
async def assign_db(request: Request):
    slot = await request.json()
    assign_slot(str(slot))
    return Response(f"Memories Assigned")

#Delete collections corresponding to a save slot
@chat_server.post("/delete_save_slot")
async def assign_db(request: Request):
    slot = await request.json()
    Memory.delete_save_slot(str(slot))
    return Response(f"Memories Deleted")



@chat_server.get("/agents")
async def get_agents():
    """ API endpoint to retrieve the list of available agents"""
    return {"agents": list(agent_obj_map.keys())}

@chat_server.post("/set_memory")
async def set_memory_endpoint(request: Request):
    """ API endpoint to set memory for an agent\n
        Expects query parameters:
        - agent: Name of the agent
        - participant: Participant identifier (default: 'user')
        - message: Message to be added to memory
        - time: Timestamp of the message
    """
    data: dict = await request.json()

    if not isinstance(data.get("message"), str) or not isinstance(data.get("agent"), str):
        raise HTTPException(status_code=400, detail="Invalid messages format")

    agent_name = data.get("agent","")
    message = data.get("message", "")
    time_stamp = data.get("time","")
    participant = data.get("participant", USER)

    if agent_name not in agent_obj_map:
        raise HTTPException(status_code=404, detail=f"Agent {agent_name} not found")

    agent = agent_obj_map[agent_name]

    memory_message = f"On {time_stamp}, you were asked/told by {participant}: {message}."
    agent.memory.add(role="user" ,message=memory_message,time_stamp=time_stamp)

    return Response(status_code=204)


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
    data: dict = await request.json()

    if not isinstance(data.get("message"), str) or not isinstance(data.get("agent"), str):
        raise HTTPException(status_code=400, detail="Invalid messages format")
    
    agent = data.get("agent","")
    message = data.get("message", "")
    time_stamp = data.get("time","")
    participant = data.get("participant", USER)

    if agent not in agent_obj_map:
        raise HTTPException(status_code=404, detail=f"Agent {agent} not found")


    return StreamingResponse(agent_obj_map[agent].chat(participant, message,time_stamp), media_type="text/event-stream")


@chat_server.post("/chat/start_ai_chat")
async def start_ai_chat_endpoint(request: Request):
    """ API endpoint to start a chat with an agent\n
        This endpoint allows users to initiate a chat session with a specific agent.
    """
    data: dict = await request.json()

    if not isinstance(data.get("message"), str) or not isinstance(data.get("agent"), str):
        raise HTTPException(status_code=400, detail="Invalid messages format")
    
    agent = data.get("agent","")
    message = data.get("message", "")
    time_stamp = data.get("time","")
    participant = data.get("participant", USER)

    if agent not in agent_obj_map:
        raise HTTPException(status_code=404, detail=f"Agent {agent} not found")

    return StreamingResponse(agent_obj_map[agent].start_ai_chat(participant, message, time_stamp), media_type="text/event-stream")


@chat_server.post("/action")
async def action_endpoint(request: Request):
    """ API endpoint for handling actions\n

    This endpoint should receive a request from Godot which is something like:
    Pick an action from this array that you feel like should be done now {[action_array]}. Ouput only the action

    This sends back the response , which is the resultant action, back to Godot and the repsonse is saved in memory. 
        

    """
    data: dict = await request.json()

    if not isinstance(data.get("action_list"),list):
        raise HTTPException(status_code=404, detail="Invalid messages format")

    agent = data.get("agent", "")  # Get the agent name

    if agent not in agent_obj_map:
        raise HTTPException(status_code=404, detail=f"Agent {agent} not found")

    action_dict = await agent_obj_map[agent].act(data)  # Wait for response
    
    return JSONResponse(action_dict)


@chat_server.post("/update_recency")
async def recency_endpoint(request: Request):
    agent_name:str = await request.json()
    
    print(f"Updating memory recencies for agent {agent_name}")

    agent: Agent = agent_obj_map[str(agent_name)] #Get agent object
    agent.memory.update_recency()
    return Response("Memory Recency Update Successful")

@chat_server.post("/get_reflections")
async def reflection_endpoint(request: Request):
    agent_name:str = await request.json()
    
    agent: Agent = agent_obj_map[str(agent_name)] #Get agent object
    await agent.reflect()
    return Response(f"{agent} had a reflection")


