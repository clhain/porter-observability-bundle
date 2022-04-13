# Porter very helpfully passes through the double quotes from the dependent bundle output to this module. Strip them.
locals {
  namespace_name = replace(var.namespace_name, "\"","")
  cluster_name = replace(var.cluster_name, "\"","")
}

provider "volterra" {
  timeout = "20s"
}

# Download the kubernetes kubeconfig for interaction with the vk8s cluster.
resource "volterra_api_credential" "this" {
  name                  = local.cluster_name
  api_credential_type   = "KUBE_CONFIG"
  virtual_k8s_namespace = local.namespace_name
  virtual_k8s_name      = local.cluster_name
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

# Create the origin pool for the eve api service
resource "volterra_origin_pool" "eve" {
  name                   = "${var.service_name}-eve-op"
  namespace              = local.namespace_name
  description            = "Origin pool for the eve API service."
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = false
      vk8s_networks   = true
      service_name    = format("%s.%s", var.service_name, local.namespace_name)
      site_locator {
        virtual_site {
          name      = var.vsite
          namespace = "shared"
          tenant    = "ves-io"
        }
      }
    }
  }
  port               = var.eve_service_port
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
}

resource "volterra_origin_pool" "app" {
  name                   = "${var.service_name}-app-op"
  namespace              = local.namespace_name
  description            = "Origin pool for the app service."
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = false
      vk8s_networks   = true
      service_name    = format("%s.%s", var.service_name, local.namespace_name)
      site_locator {
        virtual_site {
          name      = var.vsite
          namespace = "shared"
          tenant    = "ves-io"
        }
      }
    }
  }
  port               = var.app_service_port
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
}

resource "volterra_app_firewall" "this" {
  name      = "${var.name_prefix}-app-firewall"
  namespace              = local.namespace_name

  allow_all_response_codes = true
  default_anonymization = true
  use_default_blocking_page = true
  default_bot_setting = true
  default_detection_settings = true
  use_loadbalancer_setting = true
}

resource "volterra_http_loadbalancer" "this" {
  name                            = "${var.name_prefix}-loadbalancer"
  namespace                       = local.namespace_name
  description                     = "HTTPS loadbalancer object for external service"
  domains                         = [var.app_fqdn]
  advertise_on_public_default_vip = true
  default_route_pools {
    pool {
      name      = volterra_origin_pool.app.name
      namespace = local.namespace_name
    }
  }
  routes {
    simple_route {
      path {
        prefix = "/eve"
      }
      origin_pools {
        pool {
          name = volterra_origin_pool.eve.name
          namespace = local.namespace_name
        }
      }
      http_method = "ANY"
      auto_host_rewrite = true
    }
  }
  https_auto_cert {
    add_hsts      = true
    http_redirect = true
    no_mtls       = true
  }
  app_firewall {
    name      = "${var.name_prefix}-app-firewall"
    namespace = local.namespace_name
  }
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = true
}
