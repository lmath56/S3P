terraform {
    required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
        }
    }
    backend "gcs" { 
        bucket  = "s3p-tf-state" # Store the Terraform state in pre-created GCS bucket
        prefix  = "terraform/2_gcp_deploy_hf_phi"
    }
}

provider "google" {
    project = var.project_id
    region  = var.region
}

# Create storage bucket for model data https://cloud.google.com/storage/docs/terraform-create-bucket-upload-object
resource "google_storage_bucket" "gcs_bucket" {
 name          = "model-data"
 location      = var.location
 storage_class = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
 uniform_bucket_level_access = true # https://cloud.google.com/storage/docs/uniform-bucket-level-access
}

# IAM permission to allow GKE nodes to access Google Storage via FUSE
resource "google_project_iam_binding" "gke_storage_access" { # Need to check if this is implemented correctly
  project = var.project_id
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_container_cluster.gke_cluster.node_config.service_account}", # Need to understand this, need to make an account before this?
  ]
}

# Create GKE Autopilot Cluster with GPU-enabled nodes
resource "google_container_cluster" "gke_cluster" {
  name     = "gke-autopilot-cluster"
  location = var.location
  node_locations = var.node_locations
  enable_autopilot = true
  remove_default_node_pool = true 

  # Optional: Network configuration (creates default VPC) # Do I want to do this or should I create a custom VPC?
  network = google_compute_network.gke_network.id
  subnetwork = google_compute_subnetwork.gke_subnet.id
}


# https://cloud.google.com/kubernetes-engine/docs/quickstarts/create-cluster-using-terraform
resource "google_compute_network" "default" {
  name = "example-network"

  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true # IPV6? Do I want this?
}

resource "google_compute_subnetwork" "default" {
  name = "example-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "INTERNAL" # Change to "EXTERNAL" if creating an external loadbalancer  # IPV6? Do I want this? 

  network = google_compute_network.default.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range { # Do I need this?
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}

# Create a node pool with GPU accelerators and preemptible instances (?)
resource "google_container_node_pool" "node_pool" {
  name       = "node-pool"
  cluster    = google_container_cluster.autopilot_cluster.name
  location   = google_container_cluster.autopilot_cluster.location
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium" # Need to check these, how to add GPU?

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

