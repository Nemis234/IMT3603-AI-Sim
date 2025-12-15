FROM python:3.13.9-slim

# Install git
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Set base working directory
WORKDIR /app

# Clone Git repository 
RUN git clone --branch Godot-Frontend https://github.com/Nemis234/IMT3603-AI-Sim.git /app

# Install Python dependencies
RUN pip install --no-cache-dir -r /app/AI-Server/requirements

# Set working directory to server dir
WORKDIR /app/AI-Server

EXPOSE 8000

# Command to startup server
CMD ["uvicorn", "main_gemini:chat_server", "--host", "0.0.0.0", "--port", "8000"]
