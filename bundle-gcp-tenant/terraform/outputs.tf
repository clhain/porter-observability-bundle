output "username" {
  value = var.username
}
output "kubeconfig" {
  description = "kubeconfig"
  value       = module.k8s_cluster.kubeconfig_file
}

output "kubeconfig_content" {
  description = "kubeconfig"
  value       = module.k8s_cluster.kubeconfig_file_content
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.k8s_cluster.cluster_name
}

output "project_id" {
  description = "GKE cluster name"
  value       = var.gcp_project_id
}

output "region" {
  description = "GCP region"
  value       = var.gcp_region
}

output "cluster_ingress_ip" {
  description = "Static IP of the GKE Cluster Ingress"
  value = module.k8s_cluster.cluster_ingress_ip
}