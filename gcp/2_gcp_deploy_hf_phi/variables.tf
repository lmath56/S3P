# GCP project ID
variable "project_id" {
  type        = string
  description = "optimal-carving-438111-h3"
}

variable "region" {
  type        = string
  description = "eurpoe-west3"
}

variable "location" {
  type        = string
  description = "europe-west3"
}

variable "zone" {
  type        = string
  description = "europe-west3-a"
}

variable "cluster_name" {
  type        = string
  description = "gke-hf-phi"
}

variable "node_locations" {
  type        = list(string)
  description = "europe-west3-a, europe-west3-b, europe-west3-c"
}

# Options: nvidia-tesla-k80, nvidia-tesla-p100, nvidia-tesla-p4, nvidia-tesla-v100, 
# nvidia-tesla-t4, nvidia-tesla-a100, nvidia-a100-80gb, nvidia-l4
variable "gpu_type" {
  type        = string
  description = "required gpu type out of these: nvidia-tesla-k80, nvidia-tesla-p100, nvidia-tesla-p4, nvidia-tesla-v100, nvidia-tesla-t4, nvidia-tesla-a100, nvidia-a100-80gb, nvidia-l4"
}

variable "gpu_driver_version" {
  type        = string
  description = "DEFAULT"
}

