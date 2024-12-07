# Base image with GPU support
FROM nvidia/cuda:12.6.2-runtime-ubuntu22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  python3-pip

# Install transformers library 
RUN pip3 install transformers

# Install torch library
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu127

# Install Flask 
RUN pip3 install flask

# Copy the pre-downloaded model
COPY ./models /app/models

# Set the working directory
WORKDIR /app

# Copy the entrypoint script
COPY entrypoint.py /app/entrypoint.py

# Expose the port for the Flask API
EXPOSE 5000

# Run the entrypoint script
CMD ["python3", "/app/entrypoint.py"]