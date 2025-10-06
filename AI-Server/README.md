## Requirements:
ollama (downloaded from https://ollama.com/)
gemma-3 (after downloading ollama, do ```ollama run gemma3```)
Python libraries: 
- ollama-python
- fastapi
- uvicorn (or any other ASGI API host)

## Setup
- Navigate to the directory "AI-Server"
- Create a virtual environment (skip if you are installing Python packages globally)
    - Open a terminal in the AI-Server directory
    - Make the python venv: ```python -m venv ai_venv``` (use python3 for linux and macOS systems)
    - Start the env:
        - Windows: ```./ai_venv/Scripts/activate```
        - Linux/macOS: ```source ./ai_venv/Scripts/activate```
- Install packages from the requirements file:  ```pip install -r requirements```
- Start the server using uvicorn: ```uvicorn main:chat_server```