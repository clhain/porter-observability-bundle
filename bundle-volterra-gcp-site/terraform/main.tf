resource "volterra_cloud_credentials" "gcp" {
  name        = format("%s-cred", var.site_name)
  description = format("GCP credential will be used to create site %s", var.site_name)
  namespace   = "system"
  gcp_cred_file {
    credential_file{
      clear_secret_info {
        url = format("string:///%s", filebase64(var.gcp_cred_file_path))
      }
    }
  }
}
resource "volterra_gcp_vpc_site" "this" {
  name      = "applab-${var.site_name}-gcp-vpc"
  namespace = "system"
  labels    = { "ves.io/siteName" = "applab-${var.site_name}-gcp-vpc" }

  // One of the arguments from this list "cloud_credentials assisted" must be set
  cloud_credentials {
    name      = format("%s-cred", var.site_name)
    namespace = "system"
  }

  gcp_region    = var.gcp_region
  instance_type = var.machine_type
  // One of the arguments from this list "log_receiver logs_streaming_disabled" must be set
  logs_streaming_disabled = true
  lifecycle {
    ignore_changes = [labels]
  }
  // One of the arguments from this list "ingress_gw ingress_egress_gw voltstack_cluster" must be set

	ingress_egress_gw {
		gcp_certified_hw = "gcp-byol-multi-nic-voltmesh"

    gcp_zone_names = [var.gcp_zone]

    inside_network {
      new_network {
        name = "applab-${var.site_name}-inside-network"
      }
    }
    inside_subnet{
      new_subnet {
        primary_ipv4 = var.inside_subnet
        subnet_name = "applab-${var.site_name}-inside-subnet"
      }
    }
    outside_network {
      new_network {
        name = "applab-${var.site_name}-outside-network"
      }
    }
    outside_subnet{
      new_subnet {
        primary_ipv4 = var.outside_subnet
        subnet_name = "applab-${var.site_name}-outside-subnet"
      }
    }
    node_number = var.node_number
  }
}

resource "volterra_tf_params_action" "this" {
  site_name  = "applab-${var.site_name}-gcp-vpc"
  site_kind  = "gcp_vpc_site"
  action     = "apply"
  depends_on = [volterra_gcp_vpc_site.this]
}
