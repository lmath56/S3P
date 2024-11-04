# Semester 3 Personal Project

This file contains the files from my University Semester 3 Personal project, which is to work with Kubernetes to understand how it can be used for scaling AI services. 

The project revolves around the below:
- Running AI workloads locally
- Running AI workloads in Kubernees
- Using Terraform (IaC) to deploy enviroments to Google Kubernetes Engine (GKE)
- Using Terraform to deploy AI workloads to GKE
- Autoscaling AI workloads in GKE

## Repository Structure

The repository is organized into the following folders:

### `local`

The `local` folder contains scripts, configurations, and resources needed to run AI workloads on your local machine. This includes:
- Dockerfiles for building local AI service images
- Kubernetes manifests for local deployment
- Scripts for setting up and running AI services locally

### `gcp`

The `gcp` folder contains Terraform configurations and Kubernetes manifests for deploying AI workloads to Google Cloud Platform (GCP). This includes:
- Terraform scripts for provisioning GKE clusters and other necessary infrastructure
- Kubernetes manifests for deploying AI services to GKE
- Configuration files for autoscaling AI workloads in GKE

Each of these folders contains numbered folders containging different attempts.
Each will contain a `readme.md` file explaining the contents of that directory.

# Useful Commands

## Minikube

[Minikube](https://minikube.sigs.k8s.io/docs/) is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

To run a Docker container in Minikube, follow these steps:

### Configure and Start Minikube

1. Set the CPU and memory for Minikube:
    ```sh
    minikube config set cpus 8
    minikube config set memory 16384
    ```

2. Start Minikube with GPU support and Docker driver:
    ```sh
    minikube start --driver=docker --gpus=all
    ```

### Build and Load the Docker Image

1. Build the Docker image if it is not already:
    ```sh
    docker build -t hf-gpu .
    ```

2. Load the Docker image into Minikube:
    ```sh
    minikube image load hf-gpu
    ```

### Mount Local Directory

Mount a local directory containing the models to Minikube:
```sh
minikube mount C:\code\S3P\models\HF-Phi:/models
```
This is best done on a new terminal window as it must stay active while mounted.

> [!NOTE]  
> Additional config is required in the Kubernetes deployment.yaml file to mount this to the pod.

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

## Terraform

 [Terraform](https://www.terraform.io/) is an infrastructure as code tool that enables you to safely and predictably provision and manage infrastructure in any cloud.

### **Prerequisites:**

* A Google Cloud Platform (GCP) project with billing enabled.
* A Google Cloud Platform project with the necessary API permissions.
* Terraform installed and configured.

### **Setup:**

1. **Initialise Terraform:**

   ```bash
   terraform init
   ```

2. **Configure Terraform:**

   Set up your Google Cloud credentials using `gcloud auth configure`. Ensure the `project` and `region` variables in the `provider "google"` block are set correctly. For example:

    ```bash
    gcloud container clusters get-credentials gke-hf-phi --region europe-west3
    ```
    
3. **Plan and Apply Infrastructure:**

   ```bash
   terraform plan
   terraform apply
   ```

### **Commands:**

* **Initialise Terraform:**
  ```bash
  terraform init
  ```
* **Plan the Infrastructure:**
  ```bash
  terraform plan
  ```
* **Apply the Infrastructure:**
  ```bash
  terraform apply
  ```
* **Destroy the Infrastructure:**
  ```bash
  terraform destroy
  ```

## Kubectl

[`kubectl`](https://kubernetes.io/docs/reference/kubectl/) is a command-line tool used to communicate with Kubernetes clusters. It allows you to manage and inspect cluster resources, such as pods, services, deployments, and more.

### Authenticating with GKE

To interact with your GKE cluster, you'll need to authenticate your `kubectl` client. This can be done using `gcloud` or by setting up service account authentication.
```bash
gcloud container clusters get-credentials gke-hf-phi --region europe-west3
```

### Common `kubectl` Commands

#### Get Resources:
```bash
kubectl get pods
kubectl get services
kubectl get deployments
kubectl get nodes
```

#### Describe Resources:
```bash
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe deployment <deployment-name>
kubectl describe node <node-name>
```

#### Create Resources:
```bash
kubectl create deployment my-deployment --image=my-image
```

#### Delete Resources:
```bash
kubectl delete pod <pod-name>
kubectl delete service <service-name>
kubectl delete deployment <deployment-name>
```

#### Apply Configuration:
```bash
kubectl apply -f my-manifest.yaml
```

This command will configure your kubectl client to use the correct credentials to interact with your cluster.

## Google Cloud Platform 

### See which machine types are available in a zone

`gcloud compute machine-types list --zones=europe-west4-a`

### See which accelerator types are available in a Zone

 `gcloud compute accelerator-types list --filter="zone:( europe-west4-b )"`

### See which TPUs are available in a zone

`gcloud compute tpus accelerator-types list --zone=europe-west4-a`

