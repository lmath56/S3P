terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

resource "google_storage_bucket" "terraform_state" {
  name          = "terraform_state"
  location      = "europe-west4"
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  ignore_changes = [
      name,
      location,
      storage_class,
      uniform_bucket_level_access,
    ]
  }
}

terraform {
  backend "gcs" {
    bucket = "terraform_state"
    prefix = "terraform/state/3_gcp_tpu_storage"
  }
}

# Create storage bucket for model data
resource "google_storage_bucket" "gcs_bucket" {
  name                        = "s3-model-data-oc"
  location                    = "europe-west4"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name,
      location,
      storage_class,
      uniform_bucket_level_access,
    ]
  }
}

resource "google_storage_bucket" "terraform_state" {
  name          = "terraform_state"
  location      = "europe-west4"
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  ignore_changes = [
      name,
      location,
      storage_class,
      uniform_bucket_level_access,
    ]
  }
}

terraform {
  backend "gcs" {
    bucket = "terraform_state"
    prefix = "terraform/state/3_gcp_tpu_node"
  }
}