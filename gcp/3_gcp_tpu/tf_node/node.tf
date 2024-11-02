terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}


terraform {
  backend "gcs" {
    bucket = "terraform_state"
    prefix = "terraform/state/3_gcp_tpu_node"
  }
}

provider "google" {
  project = "optimal-carving-438111-h3"
  region  = "europe-west4"
}

# Create a node pool with TPUs
resource "google_container_node_pool" "tpu_node_pool" {
  cluster    = "gke-hf-phi"
  location   = "europe-west4-a"
  node_count = 1

  node_config {
    machine_type = "c4-standard-8"
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
 }
}