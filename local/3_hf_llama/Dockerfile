# Base image with GPU support
FROM nvidia/cuda:12.6.2-runtime-ubuntu22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  sudo \
  python3-pip

# Configure NVIDIA Production repositories and install nvidia-container-toolkit as per https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

RUN apt-get update && apt-get install -y \
  nvidia-container-toolkit

# Install transformers library 
RUN pip3 install transformers

# Install required librarys for model
# Torch library
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu127
# Safetensor library
RUN pip3 install safetensors

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