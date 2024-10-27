# Fourth Attempt Local

This directory contains the files for the forth attempt at local deployment. 
These files are taken from /gcp/2_gcp_deploy_hf_phi, which were orginally taken from local attempt 3_hf_phi.
These were modified to work with GCP and also use a bind point / mounted directory to access the model rather than including it in the image.  

I have [reached the limit of the Google $300 trial](https://github.com/lmath56/S3P/issues/1), so I will continue here with local implementation.  


## About the files in this directory

Uses:
- Huggingface
- [Phi-3.5-mini-instruct](https://huggingface.co/microsoft/Phi-3.5-mini-instruct)

## Basic instrutions

### Build the Docker image
```docker build -t hf-gpu .```

Replace ```hf-gpu``` with whatever you want to call the image.

### Run the Docker container
```docker run -p 5000:5000 --gpus all hf-gpu```

### Make a request to the running container
```curl -X POST http://localhost:5000/chat -H "Content-Type: application/json" -d '{"prompt": "How hot is the sun."}'```

#### Prerequisites

- Docker installed on your machine
- (Optional) NVIDIA Container Toolkit installed for GPU support

## Installing NVIDIA Container Toolkit

1. **Install NVIDIA Driver**:
    - Ensure you have the latest NVIDIA driver installed on your machine. You can download it from the [NVIDIA website](https://www.nvidia.com/Download/index.aspx).

2. **Install Docker**:
    - Make sure Docker is installed on your machine. You can download Docker Desktop from the [Docker website](https://www.docker.com/products/docker-desktop).

3. **Install WSL 2**:
    - Docker Desktop on Windows requires WSL 2. Follow the instructions to install WSL 2 from the [Microsoft documentation](https://docs.microsoft.com/en-us/windows/wsl/install).

4. **Install NVIDIA Container Toolkit**:
    - Open a WSL 2 terminal and run the following commands from [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt) to install the NVIDIA Container Toolkit.

5. **Verify Installation**:
    - Run the following command to verify that the NVIDIA Container Toolkit is installed correctly:
    ```sh
    docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
    ```

If the above command shows the GPU details, your setup is correctly utilizing the GPU.


## Download the Model from Hugging Face

Before building the Docker image, you need to download the model from Hugging Face.

1. Install the `transformers` library if you haven't already:
    ```sh
    pip install transformers
    ```

2. Download the model:
    ```python
    from transformers import AutoModelForCausalLM, AutoTokenizer

    model_name = "microsoft/Phi-3.5-mini-instruct"
    model = AutoModelForCausalLM.from_pretrained(model_name)
    tokenizer = AutoTokenizer.from_pretrained(model_name)

    model.save_pretrained("./models")
    tokenizer.save_pretrained("./models")
    ```

## Build the Docker Image

1. Build the Docker image:
    ```sh
    docker build -t hf-gpu .
    ```

    Replace `hf-gpu` with whatever you want to call the image.

## Run the Docker Container

1. Run the Docker container:
    ```sh
    docker run -p 5000:5000 --gpus all hf-gpu
    ```

## Make a Request to the Running Container


1. Use `curl` to make a POST request to the running container:

```sh
curl -X POST http://localhost:5000/chat -H "Content-Type: application/json" -d '{"prompt": "How hot is the sun."}'
```


## Changing the Model

If you want to use a different model, follow these steps:

1. Download the new model using the `transformers` library.

2. Replace the files in the "./models" directory with the new files. If this folder does not exist yet, create it manually.

3. Rebuild the Docker image:
    ```sh
    docker build -t hf-gpu .
    ```

4. Run the Docker container with the new model:
    ```sh
    docker run -p 5000:5000 --gpus all hf-gpu
    ```

Now your Docker container will use the new model for generating responses.

> [!NOTE]  
> Not all models are compatible, so changes to prerequisites, drivers, or the entrypoint.py file may be needed.
