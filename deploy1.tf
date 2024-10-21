provider "google" {
    project = "optimal-carving-438111-h3"
    region  = "europe-west3"
}

terraform {
    backend "gcs" {
        bucket  = "s3p-tf-state"
        prefix  = "terraform/state"
    }
}

# Enable the required APIs
resource "google_project_service" "compute_api" {
    service = "compute.googleapis.com"
    disable_dependent_services = true
  
}

resource "google_project_service" "container_api" {
    service = "container.googleapis.com" 
    disable_dependent_services = true
 
}

# Create a VPC network
resource "google_compute_network" "vpc-network" {
    name = "s3p-vpc"
    routing_mode = "REGIONAL"
    auto_create_subnetworks = "false"
    mtu = 1460
    delete_default_routes_on_create = false

    depends_on = [ 
        google_project_service.compute_api,
        google_project_service.container_api
    ]
}

# Create a subnet
resource "google_compute_subnetwork" "vpc-subnet" {
    name = "s3p-subnet"
    ip_cidr_range = "10.0.0.0/18"
    region = "europe-west3"
    network = google_compute_network.vpc-network.self_link
    private_ip_google_access = true

    secondary_ip_range {
        range_name = "k8s-pods-range"
        ip_cidr_range = "10.48.0.0/14"
    }

    secondary_ip_range {
        range_name = "k8s-services-range"
        ip_cidr_range = "10.52.0.0/20"
    }
}

# Create a router and NAT
resource "google_compute_router" "s3p-router" {
  name = "s3p-router"
  region = "europe-west3"
  network = google_compute_network.vpc-network.self_link
}

resource "google_compute_address" "s3p-nat-ip" {
  name = "s3p-nat-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute_api] 
}

resource "google_compute_router_nat" "s3p-nat" {
  name = "s3p-nat"
  router = google_compute_router.s3p-router.name
  region = "europe-west3"
  
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option = "MANUAL_ONLY"

  subnetwork {
    name = google_compute_subnetwork.vpc-subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

    nat_ips = [google_compute_address.s3p-nat-ip.self_link]
}

# Create a firewall rule to allow SSH
resource "google_compute_firewall" "allow-ssh" {
    name = "allow-ssh"
    network = google_compute_network.vpc-network.self_link
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"] 
}

# Create a GKE cluster
resource "google_container_cluster" "s3p-cluster" {
    name = "s3p-cluster"
    location = "europe-west3"
    network = google_compute_network.vpc-network.self_link
    subnetwork = google_compute_subnetwork.vpc-subnet.self_link
    remove_default_node_pool = true
    initial_node_count = 1
    logging_service = "logging.googleapis.com/kubernetes"
    monitoring_service = "monitoring.googleapis.com/kubernetes"
    networking_mode = "VPC_NATIVE"

    node_locations = ["europe-west3-a", "europe-west3-b", "europe-west3-c"]

    addons_config {
        horizontal_pod_autoscaling {
            disabled = false
        }
        http_load_balancing {
            disabled = true
        }
    }

    release_channel {
        channel = "REGULAR"
    }

    workload_identity_config {
        workload_pool = "optimal-carving-438111-h3.svc.id.goog"
    }

    ip_allocation_policy {
      cluster_secondary_range_name = "k8s-pods-range"
      services_secondary_range_name = "k8s-services-range"
    }

    private_cluster_config {
      enable_private_nodes = true
      enable_private_endpoint = false
      master_ipv4_cidr_block = "172.16.0.0/28"
    }
}

# Create a service account for GKE
resource "google_service_account" "gke-sa" {
    account_id = "gke-sa"
    display_name = "GKE Service Account"
}

# Create a node pool
resource "google_container_node_pool" "general" {
    name = "general-pool"
    location = "europe-west3"
    cluster = google_container_cluster.s3p-cluster.id
    node_count = 1
    
    management {
        auto_repair = true
        auto_upgrade = true
    }

    node_config {
        preemptible = false
        machine_type = "e2-small"
        
        labels = {
            role = "general"
        }
        
        service_account = google_service_account.gke-sa.email
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}

resource "google_container_node_pool" "spot" {
    name = "spot-pool"
    location = "europe-west3"
    cluster = google_container_cluster.s3p-cluster.id

    management {
        auto_repair = true
        auto_upgrade = true
    }

    autoscaling {
        min_node_count = 0
        max_node_count = 3
    }

    node_config {
        preemptible = true
        machine_type = "e2-small"

        labels = {
            role = "spot"
        }
        
        taint {
            key = "instance_type"
            value = "spot"
            effect = "NO_SCHEDULE"
        }

        service_account = google_service_account.gke-sa.email
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}