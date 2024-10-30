# Use Python base image since we don't need CUDA anymore
FROM python:3.9-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install required Python libraries
RUN pip3 install --no-cache-dir \
    torch~=2.5.0 \
    torch_xla[tpu]~=2.5.0 -f https://storage.googleapis.com/libtpu-releases/index.html \
    transformers \
    flask \
    cloud-tpu-client \
    google-cloud-tpu

# Set the working directory
WORKDIR /app

# Copy the entrypoint script
COPY entrypoint.py /app/entrypoint.py

# Expose the port for the Flask API
EXPOSE 5000

# Run the entrypoint script
CMD ["python3", "/app/entrypoint.py"]