## Requirements

| Name | Version |
|------|---------|
| volterra | 0.10.0 |

## Providers

| Name | Version |
|------|---------|
| volterra | 0.10.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_fqdn | The fqdn to advertise the for the lb. | `any` | n/a | yes |
| namespace | The name of the volterra namespace to deploy the HTTP Loadbalancer in. | `any` | n/a | yes |
| routes | The list of routes to create for the HTTP Loadbalancer. | <pre>list(object({<br>      prefix = string<br>      origin_pool_name = string<br>      origin_pool_namespace = string<br>      http_method = string<br>    }))</pre> | `[]` | no |
| service\_name | The name of the volterra vk8s service to map to. | `any` | n/a | yes |
| service\_port | The port number of the volterra vk8s service to map to. | `any` | n/a | yes |
| volt\_api\_url | The url of the volterra API server to use e.g. https://<tenant>.console.ves.volterra.io/api. | `any` | n/a | yes |

## Outputs

No output.

