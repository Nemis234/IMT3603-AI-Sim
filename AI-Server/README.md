## For deployment using python
### Requirements:
- ollama (downloaded from https://ollama.com/)
- mistral (AI model downloaded from ollama. See [setup - local server](#local-server))
- Python 3.13.7 or above (have been tested)
- Python libraries (see [setup](#setup)): 
    - ollama-python
    - fastapi
    - uvicorn (or any other ASGI API host)
    - chromadb
    - google-genai

### Setup
- Navigate to the directory "AI-Server"
- Open a terminal in the AI-Server directory
- Create a virtual environment (skip if you are installing Python packages globally)
    - Make the python venv: ```python -m venv ai_venv``` (use python3 for linux and macOS systems)
    - Start the venv (unless it is automatically initiated):
        - Windows: ```./ai_venv/Scripts/activate```
        - Linux/macOS: ```source ./ai_venv/bin/activate```
- Install packages from the requirements file:  ```pip install -r requirements```

#### Local server
To start a local server, follow the above steps, and then:
- Restart or launch your terminal window (editors like VS Code need to be fully closed and reopened)
- If ollama is downloaded, do ```ollama run mistral```
- Start the server using uvicorn for local models: ```uvicorn main:chat_server```

#### Gemini flash server
To start the Gemini flash server, follow the above steps, and then:
- Generate your own API key: https://ai.google.dev/gemini-api/docs/quickstart#before_you_begin
- Set up an API Key in Gemini Flash. Make sure to choose the appropriate operating system: https://ai.google.dev/gemini-api/docs/api-key#set-api-env-var
- Restart or launch your terminal window (editors like VS Code need to be fully closed and reopened)
- Start the server using uvicorn for gemini api:  ```uvicorn main_gemini:chat_server```

## For deployment using Docker
### Requirements:
- Docker Engine (with docker-compose)
- Google Gemini API key

### Setup
- Instructions on how to install and setup Docker for your system can be found here: https://docs.docker.com/engine/install/
- Generate your own API key: https://ai.google.dev/gemini-api/docs/quickstart#before_you_begin
    - Replace your API key in the example.env
    - Then simply copy the content from example.env over to a .env file
        - On linux you can do this:
        ```bash
        cp example.env .env
        ```

### Starting the server
Be sure that the Docker engien is running on the device, then in this directory do: 
```bash
docker compose up -d
```
