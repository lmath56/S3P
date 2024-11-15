terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
  backend "gcs" {
    bucket = "s3p_terraform_state"
    prefix = "terraform/state/greenroom/sentiment"
  }
}

provider "google" {
  project = "optimal-carving-438111-h3"
  region  = "europe-west4"
}

# Enable required APIs for GKE cluster
resource "google_project_service" "compute_api" {
  project             = "optimal-carving-438111-h3"
  service             = "compute.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "container_api" {
  project             = "optimal-carving-438111-h3"
  service             = "container.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "iam_api" {
  project             = "optimal-carving-438111-h3"
  service             = "iam.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "storage_api" {
  project             = "optimal-carving-438111-h3"
  service             = "storage.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "tpu_api" {
  project             = "optimal-carving-438111-h3"
  service             = "tpu.googleapis.com"
  disable_on_destroy  = false
}

# Create VPC network and subnet for GKE cluster
resource "google_compute_network" "gke_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute_api]
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "europe-west4"
  network       = google_compute_network.gke_network.id
}

# Create firewall rule to allow external access to nodes
resource "google_compute_firewall" "default-allow-http" {
  name    = "default-allow-http"
  network = google_compute_network.gke_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create GKE Standard Cluster
resource "google_container_cluster" "gke_cluster" {
  name                = "greenroom-sentiment-cluster"
  location            = "europe-west4-a"
  initial_node_count  = 1
  network             = google_compute_network.gke_network.name
  subnetwork          = google_compute_subnetwork.gke_subnet.name
  deletion_protection = false
  remove_default_node_pool = true

  workload_identity_config {
    workload_pool = "optimal-carving-438111-h3.svc.id.goog"
  }
}

# Create a node pool with autoscaling
resource "google_container_node_pool" "node_pool" {
  cluster    = google_container_cluster.gke_cluster.name
  location   = "europe-west4-a"
  node_count = 1
  
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = "e2-medium"
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}