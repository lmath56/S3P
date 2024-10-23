provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "YOUR_REGION"
}

# Google Storage Bucket
resource "google_storage_bucket" "ai_model_bucket" {
  name          = "ai-model-bucket"
  location      = var.region
  force_destroy = true
}

# Google Kubernetes Engine (GKE) Cluster in Autopilot Mode
resource "google_container_cluster" "autopilot_cluster" {
  name     = "autopilot-cluster"
  location = var.region

  autopilot {
    enabled = true
  }

  node_config {
    # Enabling GPU for nodes
    guest_accelerator {
      type  = "nvidia-tesla-k80" # Adjust according to your GPU requirement
      count = 1
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
}

# Google Storage FUSE on GKE Nodes
resource "google_storage_bucket_iam_member" "storage_access" {
  bucket = google_storage_bucket.ai_model_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_container_cluster.autopilot_cluster.workload_identity_config.identity_namespace}"
}

# Load Balancer
resource "google_compute_address" "lb_ip" {
  name = "load-balancer-ip"
}

resource "google_compute_firewall" "default" {
  name    = "default-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_backend_service" "default" {
  name                  = "default-backend"
  port_name             = "http"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_container_node_pool.default.instance_group_urls[0]
  }

  health_checks = [google_compute_health_check.default.self_link]
}

resource "google_compute_http_health_check" "default" {
  name               = "default-health-check"
  request_path       = "/"
  port               = "80"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
}

resource "google_compute_url_map" "default" {
  name            = "default-url-map"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_target_http_proxy" "default" {
  name    = "default-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_forwarding_rule" "default" {
  name        = "default-forwarding-rule"
  target      = google_compute_target_http_proxy.default.self_link
  port_range  = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_address  = google_compute_address.lb_ip.address
}

# Variables
variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
  default     = "YOUR_PROJECT_ID"
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "YOUR_REGION"
}
