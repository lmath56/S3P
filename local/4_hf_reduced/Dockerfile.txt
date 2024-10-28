# Use a minimal base image with CUDA support
FROM nvidia/cuda:12.6.2-runtime-ubuntu22.04

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install required Python libraries
RUN pip3 install --no-cache-dir \
    torch \
    safetensors \
    transformers \
    flask

# Set the working directory
WORKDIR /app

# Copy the entrypoint script
COPY entrypoint.py /app/entrypoint.py

# Expose the port for the Flask API
EXPOSE 5000

# Run the entrypoint script
CMD ["python3", "/app/entrypoint.py"]