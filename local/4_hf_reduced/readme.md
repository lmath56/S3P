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

Build the Docker image:
```sh
docker build -t hf-gpu .
```

Replace `hf-gpu` with whatever you want to call the image.

## Run the Docker Container

Run the Docker container:
```sh
docker run -p 5000:5000 --gpus all hf-gpu
```

## Make a Request to the Running Container


Use `curl` to make a POST request to the running container:

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


## Running in Minikube

To run the Docker container in Minikube, follow these steps:

### Configure Minikube

1. Set the CPU and memory for Minikube:
    ```sh
    minikube config set cpu 8
    minikube config set memory 16384
    ```

2. Start Minikube with GPU support and Docker driver:
    ```sh
    minikube start --driver=docker --gpus=all
    ```

### Build and Load the Docker Image

1. Build the Docker image:
    ```sh
    docker build -t hf-gpu .
    ```

2. Load the Docker image into Minikube:
    ```sh
    minikube image load hf-gpu
    ```

### Mount Local Directory

Mount the local directory containing the models to Minikube:
```sh
minikube mount C:\code\S3P\models\HF-Phi:/models
```

### Deploy to Minikube

Apply the Kubernetes deployment and service configuration:
```sh
kubectl apply -f deploy.yaml
kubectl apply -f service.yaml
```

### Access the Service

Use Minikube to access the service:
```sh
minikube service ai-service
```

### Access Logs

To access the logs of the running pod:
```sh
kubectl logs <pod-name>
```
Replace `<pod-name>` with the name of your pod. You can get the pod name by running:
```sh
kubectl get pods
```

### Clean Up

When you are done, you can delete the Minikube cluster:
```sh
minikube delete
```

By following these steps, you can run your Docker container in Minikube with GPU support and access it through a Kubernetes service.

## Progression

This works, however the size of this image is not much better. Further progression is made in gcp/3_gcp_tpu