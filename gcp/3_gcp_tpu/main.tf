terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "optimal-carving-438111-h3"
  region  = "europe-west3"
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

# Create a service account for cluster to access Google Storage
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

# Create storage bucket for model data
resource "google_storage_bucket" "gcs_bucket" {
  name                        = "s3-model-data-oc"
  location                    = "europe-west3"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}

# IAM permission to allow GKE nodes to access Google Storage
resource "google_project_iam_binding" "gke_storage_access" {
  project = "optimal-carving-438111-h3"
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.gke_service_account.email}",
  ]
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
  region        = "europe-west3"
  network       = google_compute_network.gke_network.id
}

# Create GKE Standard Cluster
resource "google_container_cluster" "gke_cluster" {
  name                = "gke-hf-phi"
  location            = "europe-west3-b"
  initial_node_count  = 1
  network             = google_compute_network.gke_network.name
  subnetwork          = google_compute_subnetwork.gke_subnet.name
  deletion_protection = false

  workload_identity_config {
    workload_pool = "optimal-carving-438111-h3.svc.id.goog"
  }

  addons_config {
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }
}

# Create a node pool with NVIDIA T4 GPUs
resource "google_container_node_pool" "gpu_node_pool" {
  cluster    = google_container_cluster.gke_cluster.name
  location   = "europe-west3-b"
  node_count = 1

  node_config {
    machine_type = "n1-standard-4"
    guest_accelerator {
      type  = "nvidia-tesla-t4"
      count = 1
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# Create a node pool with TPUs
resource "google_container_node_pool" "tpu_node_pool" {
  cluster    = google_container_cluster.gke_cluster.name
  location   = "europe-west3-b"
  node_count = 1

  node_config {
    machine_type = "n1-standard-4"
    guest_accelerator {
      type  = "tpu-v2"
      count = 8
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}