# Semester 3 Personal Project

This file contains the files from my University Semester 3 Personal project, which is to work with Kubernetes to understand how it can be used for scaling AI services. 

The project revolves around the below:
- Running AI workloads locally
- Running AI workloads in Kubernees
- Using Terraform (IaC) to deploy enviroments to Google Kubernetes Engine (GKE)
- Using Terraform to deploy AI workloads to GKE
- Autoscaling AI workloads in GKE

## Repository Structure

The repository is organized into the following main folders:

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

## **GKE Cluster with GPU Node Pool**

### **Prerequisites:**

* A Google Cloud Platform (GCP) project with billing enabled.
* A Google Cloud Platform project with the necessary API permissions.
* Terraform installed and configured.

### **Setup:**

1. **Clone this Repository:**

   ```bash
   git clone https://github.com/lmath56/S3P.git
   cd S3P
   ```

> [!NOTE]  
> S3P = Semester 3 Personal (project)

2. **Initialise Terraform:**

   ```bash
   terraform init
   ```

3. **Configure Terraform:**

   Set up your Google Cloud credentials using `gcloud auth configure`. Ensure the `project` and `region` variables in the `provider "google"` block are set correctly. For example:

    ```bash
    gcloud container clusters get-credentials gke-hf-phi --region europe-west3
    ```
    
4. **Plan and Apply Infrastructure:**

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

  

# Using `kubectl` to Manage Your GKE Cluster

`kubectl` is a command-line tool used to communicate with Kubernetes clusters. It allows you to manage and inspect cluster resources, such as pods, services, deployments, and more.

## Basic Usage

To interact with your GKE cluster, you'll need to authenticate your `kubectl` client. This can be done using `gcloud` or by setting up service account authentication.

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

### Authenticating with GKE

To authenticate with your GKE cluster, use the following command:

```bash
gcloud container clusters get-credentials gke-hf-phi --region europe-west3
```

This command will configure your kubectl client to use the correct credentials to interact with your cluster.
