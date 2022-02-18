terraform {
  required_version = ">= 1.0.0"
}

provider "google-beta" {
  project = var.gcp_project_id
  region = var.gcp_region
  credentials = "/cnab/app/gcloud.json"
}

provider "google" {
  project = var.gcp_project_id
  region = var.gcp_region
  credentials = "/cnab/app/gcloud.json"
}

resource "random_string" "r_string" {
  length  = 5
  upper   = false
  number  = false
  lower   = true
  special = false
}

locals {
  name = lower(replace("${var.username}-${random_string.r_string.id}", "/[_.@]+/", "-"))
}

module "k8s_cluster" {
  source              = "./modules/gcloud-k8s"
  name                = local.name
  project             = var.gcp_project_id
  region              = var.gcp_region
  machine_type        = var.machine_type
  vpc_subnet          = var.vpc_subnet
  site_name           = var.site_name
  preemptible_nodes   = false // must be set to false for deploy from pipeline
}