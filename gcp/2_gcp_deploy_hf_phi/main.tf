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
    project = "optimal-carving-438111-h3" # GCP project ID
    region  = "europe-west3" 
}

# Create storage bucket for model data https://cloud.google.com/storage/docs/terraform-create-bucket-upload-object
resource "google_storage_bucket" "gcs_bucket" {
 name          = "model-data"
 location      = "europe-west3"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

# IAM permission to allow GKE nodes to access Google Storage via FUSE
resource "google_project_iam_binding" "gke_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_container_cluster.gke_cluster.node_config.service_account}",
  ]
}



resource "google_compute_instance" "vps_instance" {
  name         = "vps-instance"
  machine_type = "e2-medium"
  zone         = "europe-west3"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }
}

# Create the cluster
resource "google_container_cluster" "autopilot_cluster" {
  name     = "autopilot-cluster"
  location = "europe-west3"
  enable_autopilot = true
}

# Create a node pool
resource "google_container_node_pool" "node_pool" {
  name       = "node-pool"
  cluster    = google_container_cluster.autopilot_cluster.name
  location   = google_container_cluster.autopilot_cluster.location
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  }
}

resource "google_compute_http_health_check" "health_check" {
  name               = "http-health-check"
  request_path       = "/"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
}

resource "google_compute_target_pool" "target_pool" {
  name         = "target-pool"
  health_checks = [google_compute_http_health_check.health_check.self_link]
}

resource "google_compute_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_pool.target_pool.self_link
  port_range = "80"
}

