
locals {
  cluster_name = "${var.name}-cluster"
  network_name = "${var.name}-vpc"
  pod_subnet = "${var.name}-pods"
  service_subnet = "${var.name}-services"
  common_labels = {
    "owner" = var.name,
  }
}

###################################################
# Parent Site Network Data
###################################################
data "google_compute_network" "inside_network" {
  name = "${var.site_name}-inside-network"
}

###################################################
# Parent Site Inside Subnet Data
###################################################
data "google_compute_subnetwork" "inside_subnet" {
  name = "${var.site_name}-inside-subnet"
}

###################################################
# VPC
###################################################
module "gcp_network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0"
  project_id     = var.project
  network_name = local.network_name
  subnets = [
    {
      subnet_name   = "${var.name}-primary-subnet"
      subnet_ip     = var.vpc_subnet
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    "${var.name}-primary-subnet" = [
      {
        range_name    = "${var.name}-pod-subnet"
        ip_cidr_range = replace(replace(var.vpc_subnet, "/^100/", "10"), "/24", "/25")
      },
      {
        range_name    = "${var.name}-service-subnet"
        ip_cidr_range = replace(replace(var.vpc_subnet, "/^100/", "10"), "0/24", "128/25")
      },
    ]
  }
}

###################################################
# VPC Peering
###################################################
resource "google_compute_network_peering" "peering1" {
  name         = "${var.name}-peering1"
  network      = module.gcp_network.network_self_link
  peer_network = data.google_compute_network.inside_network.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "${var.name}-peering2"
  network      = data.google_compute_network.inside_network.self_link
  peer_network = module.gcp_network.network_self_link
}

###################################################
# Firewall Rules
###################################################
resource "google_compute_firewall" "default" {
  name    = "${var.name}-voltmesh-inside-firewall"
  network = module.gcp_network.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  #destination_ranges = ["${replace(var.vpc_subnet, "0/24", "2")}/32"]
  source_ranges = [data.google_compute_subnetwork.inside_subnet.ip_cidr_range]
}

###################################################
# Static IP For Cluster Ingress Service
###################################################
resource "google_compute_address" "cluster_ingress" {
  name         = "${var.name}-cluster-ingress"
  subnetwork   = module.gcp_network.subnets_names[0]
  address_type = "INTERNAL"
  address      = replace(var.vpc_subnet, "0/24", "2")
  region       = var.region
}

###################################################
# Cluster
###################################################
resource "google_container_cluster" "default" {
  name        = local.cluster_name
  project     = var.project
  description = "Demo GKE Cluster"
  location    = var.region

  //remove_default_node_pool = true
  initial_node_count       = var.initial_node_count

  provider = google-beta
  network  = module.gcp_network.network_name
  subnetwork = module.gcp_network.subnets_names[0]

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }
  depends_on = [google_compute_address.cluster_ingress]
}

data "google_client_config" "default" {
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig-template.yaml")

  vars = {
    cluster_name  = google_container_cluster.default.name
    endpoint      = google_container_cluster.default.endpoint
    cluster_ca    = google_container_cluster.default.master_auth[0].cluster_ca_certificate
    cluster_token = data.google_client_config.default.access_token
  }
}

resource "local_file" "kubeconfig" {
  content         = data.template_file.kubeconfig.rendered
  filename        = "${path.root}/${var.name}-kubeconfig"
  file_permission = "0600"
}

