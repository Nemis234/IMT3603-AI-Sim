## Requirements:
ollama (downloaded from https://ollama.com/)
ollama-python
fastapi
uvicorn (or any other REST API host)

## Setup
- Navigate to the folder "Ai Server"
- Open a terminal window, and start the env
    - Windows: ```./ai_venv/Scripts/activate```
    - Linux: ```source ./ai_venv/Scripts/activate```
- Start the server using uvicorn:
    ```uvicorn main:chat_server```