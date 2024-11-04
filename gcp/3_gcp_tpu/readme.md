# Thrid Attempt 

This directory contains the files to run an AI model in Google Kubernetes Engine using TPUs (as GPUs are disabled for the GCP trial) 


## About the files in this directory


- Uses model [HF-meta-Llama-3.2-3B-Instruct](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct) from HuggingFace
- Uses Terraform to deploy the infrastructure to Google Cloud Platform 
- Uses Kubectl to deploy the workload to Google Kubernetes Engine

## Prerequisites

Before you begin, ensure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Docker](https://www.docker.com/products/docker-desktop)

## Steps to Run the AI Model

### 1. Set Up Google Cloud Project

1. Create a new project in the [Google Cloud Console](https://console.cloud.google.com/).

### 2. Configure Terraform

1. Navigate to the directory containing the Terraform configuration files.
2. Initialize Terraform:
    ```sh
    terraform init
    ```

2. Apply the Terraform configuration to create the necessary infrastructure:
    ```sh
    terraform apply
    ```

    This will create a GKE cluster with TPU support and a storage bucket for model data.
 
### 3. Build and Push Docker Image

1. Build the Docker image:
    ```sh
    docker build -t pytorch-xla-app .
    ```

2. Tag the Docker image:
    ```sh
    docker tag pytorch-xla-app gcr.io/your-project-id/pytorch-xla-app
    ```

3. Push the Docker image to Google Container Registry:
    ```sh
    docker push gcr.io/your-project-id/pytorch-xla-app
    ```

### 4. Deploy to GKE

1. Update the `deploy.yaml` file with your project ID and other necessary details.

2. Apply the Kubernetes deployment:
    ```sh
    kubectl apply -f deployment.yaml
    ```

### 5.  Verify the Deployment
1. Check the status of the pods:
    ```sh
    kubectl get pods
    ```
   - Ensure that the pods are running and not in a crash loop.
2. Get the external IP of the service:
    ```sh
    kubectl get services
    ```
    - Note the external IP address of the pytorch-xla-app service.
3. Test the API:

    Send a POST request to the /generate endpoint using curl or any API testing tool:
    ```sh
    curl -X POST http://<external-ip>/generate -H "Content-Type: application/json" -d '{"input_text": "Hello, world!"}'
    ```
    You should receive a JSON response with the generated text.

### 6. Cleaning Up
To clean up the resources created by Terraform, run:
    ```sh
    terraform destroy
    ```
    - This will delete the GKE cluster, TPU node pool, and other resources created by the Terraform configuration.

### 7. Troubleshooting
If the pods are not running correctly, check the logs:
    ```sh
    kubectl logs <pod-name>
    ```
    - Ensure that the TPU nodes are correctly configured and available.

## Progression

This is still a work in progress. Currently the Google account used does not have enough quota.