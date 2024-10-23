provider "google" {
  project = "<YOUR_PROJECT_ID>"
  region  = "<YOUR_REGION>"  # Example: us-central1
}

# Create Google Cloud Storage Bucket to hold AI model
resource "google_storage_bucket" "ai_model_bucket" {
  name     = "ai-model-bucket"
  location = "<YOUR_REGION>"
}

# Create GKE Autopilot Cluster with GPU-enabled nodes
resource "google_container_cluster" "gke_cluster" {
  name     = "gke-autopilot-cluster"
  location = "<YOUR_REGION>"
  autopilot {
    enabled = true
  }
  # Add GPU support
  workload_metadata_config {
    node_metadata = "GKE_METADATA"
  }
  remove_default_node_pool = true

  # Optional: Network configuration (creates default VPC)
  network = google_compute_network.gke_network.id
  subnetwork = google_compute_subnetwork.gke_subnet.id
}

# Create a GPU node pool
resource "google_container_node_pool" "gpu_node_pool" {
  name       = "gpu-node-pool"
  cluster    = google_container_cluster.gke_cluster.name
  location   = google_container_cluster.gke_cluster.location

  node_config {
    machine_type = "n1-standard-8"
    accelerators {
      accelerator_count = 1
      accelerator_type  = "nvidia-tesla-k80"  # Or any other GPU type supported in your region
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  # Enable autoscaling
  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}

# Create the network for the cluster
resource "google_compute_network" "gke_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

# Create a subnet for the GKE cluster
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  region        = "<YOUR_REGION>"
  network       = google_compute_network.gke_network.id
  ip_cidr_range = "10.0.0.0/20"
}

# Create a load balancer to distribute traffic to the nodes
resource "google_compute_global_address" "static_ip" {
  name = "gke-loadbalancer-ip"
}

resource "google_compute_forwarding_rule" "http_forwarding_rule" {
  name        = "gke-http-rule"
  load_balancing_scheme = "EXTERNAL"
  target      = google_compute_target_http_proxy.default.id
  port_range  = "80"
  ip_address  = google_compute_global_address.static_ip.address
}

resource "google_compute_target_http_proxy" "default" {
  name        = "gke-http-proxy"
  url_map     = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name            = "gke-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name          = "gke-backend-service"
  port_name     = "http"
  protocol      = "HTTP"
  backend {
    group = google_compute_instance_group.gke_instance_group.self_link
  }
  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_http_health_check" "default" {
  name               = "gke-health-check"
  request_path       = "/"
}

resource "google_compute_instance_group" "gke_instance_group" {
  name        = "gke-instance-group"
  zone        = "<YOUR_ZONE>"
}

# IAM permission to allow GKE nodes to access Google Storage via FUSE
resource "google_project_iam_binding" "gke_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_container_cluster.gke_cluster.node_config.service_account}",
  ]
}
