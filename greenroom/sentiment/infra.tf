terraform { # Configure the Terraform provider and backend
  required_providers {
    google = { # https://registry.terraform.io/providers/hashicorp/google/latest
      source  = "hashicorp/google"
      version = "6.11.2"
    }
  }
  backend "gcs" { # Store Terraform state in GCS so it can be accessed via multiple machines
    bucket = "s3p_terraform_state"
    prefix = "terraform/state/greenroom/sentiment"
  }
}

provider "google" {  # Configure the Google Cloud provider with the project and region
  project = "optimal-carving-438111-h3"
  region  = "europe-west4"
}

# Enable required APIs for GKE cluster
resource "google_project_service" "compute_api" { # Enable Compute Engine API
  project             = "optimal-carving-438111-h3"
  service             = "compute.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "container_api" { # Enable GKE API
  project             = "optimal-carving-438111-h3"
  service             = "container.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "iam_api" {  # Enable IAM API
  project             = "optimal-carving-438111-h3"
  service             = "iam.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "storage_api" { # Enable Cloud Storage API
  project             = "optimal-carving-438111-h3"
  service             = "storage.googleapis.com"
  disable_on_destroy  = false
}

resource "google_compute_network" "gke_network" { # Create VPC network
  name                    = "gke-network"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute_api]
}

resource "google_compute_subnetwork" "gke_subnet" { # Create subnet 10.0.0.0/16
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "europe-west4"
  network       = google_compute_network.gke_network.id
}

resource "google_compute_firewall" "default-allow-http" { # Firewall rule external access to nodes port 8080
  name    = "default-allow-http"
  network = google_compute_network.gke_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_container_cluster" "gke_cluster" { # Create GKE Standard Cluster
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

resource "google_container_node_pool" "node_pool" { # Create a node pool with autoscaling
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