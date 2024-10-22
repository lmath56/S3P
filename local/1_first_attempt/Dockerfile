# Base image
FROM nvidia/cuda:12.6.2-runtime-ubuntu22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    python3-pip

# Install transformers library
RUN pip3 install transformers

# Install Ollama https://ollama.com/download/linux
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy the configuration file into the image
COPY ollama.yaml /root/ollama/ollama.yaml

# Copy the pre-downloaded model into the image
COPY ./models /app/models

# Expose the necessary port for accessing the service
EXPOSE 11434

# Default command to start Ollama and make it ready for prompts
CMD ["ollama", "serve --config ollama.yaml"]