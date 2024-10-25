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

