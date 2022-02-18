# resource "volterra_origin_pool" "this" {
#   name                   = "${var.name_prefix}-origin-pool"
#   namespace              = var.namespace
#   description            = format("Origin pool pointing to external service")
#   loadbalancer_algorithm = "ROUND ROBIN"
#   origin_servers {
#     public_name {
#       dns_name = var.upstream_fqdn
#     }
#   }
#   port = var.upstream_port
#   no_tls = true
#   endpoint_selection = "LOCAL_PREFERRED"
# }

resource "volterra_origin_pool" "this" {
  name                   = "${var.name_prefix}-origin-pool"
  namespace              = var.namespace
  description            = format("Origin pool pointing to external service")
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    private_ip {
      ip = var.cluster_ingress_ip
      site_locator {
        site {
          namespace = "system"
          name = var.site_name
        }
      }
      inside_network = true
    }
  }
  port = var.upstream_port
  no_tls = true
  endpoint_selection = "LOCAL_PREFERRED"
}

resource "volterra_app_firewall" "this" {
  name      = "${var.name_prefix}-app-firewall"
  namespace              = var.namespace

  allow_all_response_codes = true
  default_anonymization = true
  use_default_blocking_page = true
  default_bot_setting = true
  default_detection_settings = true
  use_loadbalancer_setting = true
}

resource "volterra_http_loadbalancer" "this" {
  name                            = "${var.name_prefix}-loadbalancer"
  namespace                       = var.namespace
  description                     = "HTTPS loadbalancer object for external service"
  domains                         = [var.app_fqdn]
  advertise_on_public_default_vip = true
  default_route_pools {
    pool {
      name      = volterra_origin_pool.this.name
      namespace = var.namespace
    }
  }
  https_auto_cert {
    add_hsts      = true
    http_redirect = true
    no_mtls       = true
  }
  app_firewall {
    name      = "${var.name_prefix}-app-firewall"
    namespace = var.namespace
  }
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = true
}
