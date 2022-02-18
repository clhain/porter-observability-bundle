variable "namespace" {
  description = "The name of the volterra namespace to deploy the HTTP Loadbalancer in."
}
variable "site_name" {
  description = "The Volterra Site name of the Origin server."
}
variable "cluster_ingress_ip"{
  description = "The IP address of the cluster ingress at the site."
}
variable "name_prefix" {
  description = "The name prefix for the loadbalancer components."
  default = "my-loadbalancer"
}
variable "upstream_port" {
  description = "The port number of the upstream service."
}
variable "app_fqdn" {
  description = "The fqdn to advertise the for the lb."
}