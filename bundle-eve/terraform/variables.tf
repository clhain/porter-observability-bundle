variable "namespace_name" {
  description = "The name of the volterra namespace to deploy to."
}

variable "cluster_name" {
  description = "The name of the volterra vk8s to deploy to."
}

variable "name_prefix" {
  description = "The name prefix for the loadbalancer components."
  default = "my-loadbalancer"
}

variable "app_fqdn" {
  description = "The fqdn to advertise the for the lb."
}

variable "service_name" {
  description = "The name of the volterra vk8s service to map to."
  default = "project-eve"
}
variable "eve_service_port" {
  description = "The port number of the volterra vk8s service to map to."
  default = "8080"
}
variable "app_service_port" {
  description = "The port number of the volterra vk8s service to map to."
  default = "8081"
}
variable "vsite" {
  description = "The VSite where the application is served from."
  default = "ves-io-all-res"
}