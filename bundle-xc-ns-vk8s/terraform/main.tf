resource "random_id" "this" {
  byte_length = 4
}

provider "volterra" {
  api_p12_file     = "/cnab/app/.volterra/creds.p12"
}

# Create the volterra namespace and sleep 10s to prevent creation failures for child objects. 
resource "volterra_namespace" "this" {
  name = var.name != "" ?  var.name : "${var.name_prefix}-${random_id.this.hex}"
  provisioner "local-exec" {
    command = "sleep 10s"
  }
}

# Create the virtual kubernetes cluster in the namespace.
resource "volterra_virtual_k8s" "this" {
  name        = "${volterra_namespace.this.name}-vk8s"
  namespace   = volterra_namespace.this.name
  description = "Virtual Kubernetes Cluster For ${volterra_namespace.this.name}"

  vsite_refs {
    name      = var.vsite
    tenant    = "ves-io"
    namespace = "shared"
  }
  # Workaround for cluster not ready to provision API credentials.
  provisioner "local-exec" {
    command = "sleep 100s"
  }
}

# Download the kubernetes kubeconfig for interaction with the vk8s cluster.
resource "volterra_api_credential" "this" {
  name                  = "${volterra_namespace.this.name}-vk8s-cred"
  api_credential_type   = "KUBE_CONFIG"
  virtual_k8s_namespace = volterra_namespace.this.name
  virtual_k8s_name      = volterra_virtual_k8s.this.name
  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

# Save the kubeconfig to a local file for interaction with the cluster later on.
resource "local_file" "this_kubeconfig" {
  content  = base64decode(volterra_api_credential.this.data)
  filename = format("%s/_output/vk8s_kubeconfig", path.root)
}

# Wait for the kubernetes cluster to become ready to serve requests.
resource "null_resource" "wait_for_vk8s" {
  depends_on = [volterra_virtual_k8s.this, local_file.this_kubeconfig]
  provisioner "local-exec" {
    command = "while [ -n $(kubectl get ns) ]; do sleep 1; done"
    environment = {
      KUBECONFIG = format("%s/_output/vk8s_kubeconfig", path.root)
    }
  }
}