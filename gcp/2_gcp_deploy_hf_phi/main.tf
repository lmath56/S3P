terraform {
    required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
        }
    }
}

provider "google" {
    project = "optimal-carving-438111-h3"
    region  = "europe-west3" 
}

# Enable required APIs for GKE cluster
# Set to disable_on_destroy = false to ensure that the API is not disabled when the resource is destroyed as this takes time to remove and readd
resource "google_project_service" "compute_api" {
  project = "optimal-carving-438111-h3"
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_api" {
  project = "optimal-carving-438111-h3"
  service = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  project = "optimal-carving-438111-h3"
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage_api" {
  project = "optimal-carving-438111-h3"
  service = "storage.googleapis.com"
  disable_on_destroy = false
}


# Create a service account for cluster to access Google Storage
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

# Create storage bucket for model data 
# https://cloud.google.com/storage/docs/terraform-create-bucket-upload-object
resource "google_storage_bucket" "gcs_bucket" {
 name          = "s3-model-data-oc"
 location      = "europe-west3" 
 storage_class = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
 uniform_bucket_level_access = true # https://cloud.google.com/storage/docs/uniform-bucket-level-access

}

# IAM permission to allow GKE nodes to access Google Storage 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
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
  depends_on = [google_project_service.compute_api]  # Ensure Compute Engine API is enabled

}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "europe-west3" 
  network       = google_compute_network.gke_network.id
}


# Create GKE Autopilot Cluster with GPU-enabled nodes
resource "google_container_cluster" "gke_cluster" {
  name     = "gke-hf-phi"
  location = "europe-west3"
  node_locations = ["europe-west3-a", "europe-west3-b"]
  enable_autopilot = true # This will mean that Google will manage the nodes
  enable_tpu = false
  initial_node_count = 0
  network = google_compute_network.gke_network.name
  subnetwork = google_compute_subnetwork.gke_subnet.name
  deletion_protection = false

  workload_identity_config {
    workload_pool = "optimal-carving-438111-h3.svc.id.goog"
  }
  
  node_config {
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  addons_config {
    gcs_fuse_csi_driver_config { # Enable GCS FUSE CSI driver https://github.com/GoogleCloudPlatform/gcs-fuse-csi-driver/blob/main/docs/terraform.md
      enabled = true
    }   
  }
}

