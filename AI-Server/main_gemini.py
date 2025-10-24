from gemini_agent import Agent, USER
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import StreamingResponse,Response,JSONResponse
from agent_map import AGENT_DESC
               
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
        
    Expects a JSON payload with the following structure:
        {
            "agent": "AgentName",
            "message": "The agents instructions",
            "time": "timestamp"
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

   

    action_dict = await agent_obj_map[agent].act(message,time_stamp=time_stamp) #Wait for response
    return JSONResponse(action_dict)

