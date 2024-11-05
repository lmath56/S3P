# Use Python base image since we don't need CUDA anymore
FROM python:3.9-slim

# # Install required system packages
# RUN apt-get update && apt-get install -y \
#     curl \
#     gnupg2 \
#     lsb-release \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# Install required Python libraries
RUN pip3 install --no-cache-dir \
    torch \
    transformers \
    flask 

# Set the working directory
WORKDIR /app

COPY models /app/models

# Copy the entrypoint script
COPY entrypoint.py /app/entrypoint.py

# Expose the port for the Flask API
EXPOSE 5000

# Run the entrypoint script
CMD ["python3", "/app/entrypoint.py"]