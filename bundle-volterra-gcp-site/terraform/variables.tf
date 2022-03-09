variable "inside_subnet" {
  default     = "100.64.0.0/24"
  description = "The Inside Subnet to use for the VPC Node."
}
variable "outside_subnet" {
  default     = "100.64.1.0/24"
  description = "The Outside Subnet to use for the VPC Node."
}
variable "node_number" {
  default     = "1"
  description = "The number of nodes to create (1 or 3)"
}

variable "gcp_cred_file_path" {
  default     = "/cnab/app/gcloud.json"
  description = "The Volterra cloud credential path to use for auto-provisioning."
}

variable "site_name" {
  type        = string
  description = "The base label used for resource naming."
}

variable "gcp_lat" {
  type        = string
  description = "The volterra namespace to create and deploy to."
}

variable "gcp_lng" {
  type        = string
  description = "The volterra namespace to create and deploy to."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region to use"
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone to use"
}

variable "machine_type" {
  type        = string
  description = "The instance type for the cluster nodes."
  default     = "e2-standard-2"
}
