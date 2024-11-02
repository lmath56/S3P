# Use Python base image since we don't need CUDA anymore
FROM python:3.9-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the GCSFUSE_REPO environment variable
RUN export GCSFUSE_REPO=gcsfuse-$(lsb_release -c -s) \
    && echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update && apt-get install -y fuse gcsfuse


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