variable "tenant_name" {
  default = "porter-default"
}

variable "gcp_project_id" {}

variable "gcp_region" {
  default = "us-central1"
}


variable "gcp_location" {
  default = "us-central1-a"
}
variable "machine_type" {
  default = "e2-standard-2"
}

variable "vpc_subnet" {}

variable "site_name" {}