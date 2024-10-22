# Base image, choose one that supports your requirements (like Ubuntu or Alpine)
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl 

# Install Ollama https://ollama.com/download/linux
RUN curl -fsSL https://ollama.com/install.sh | sh

# Download the pretrained model
RUN ollama pull llama3.2

# Expose the necessary port for accessing the service
EXPOSE 11434

# Default command to start Ollama and make it ready for prompts
CMD ["ollama", "serve"]