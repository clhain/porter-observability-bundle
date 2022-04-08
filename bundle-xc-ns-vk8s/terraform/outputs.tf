output "namespace_name" {
  value = volterra_namespace.this.name
}
output "cluster_name" {
  value = volterra_virtual_k8s.this.name
}
# output "kubeconfig" {
#   value     = local_file.this_kubeconfig.content
# }