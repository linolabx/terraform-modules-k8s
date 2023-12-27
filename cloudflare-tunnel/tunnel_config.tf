variable "ingress_rule" {
  type = list(object({
    hostname = string
    service  = string
  }))
  default = null
}

variable "origin_server_name" {
  type    = string
  default = null
}

resource "cloudflare_tunnel_config" "lotus" {
  count = var.ingress_rule != null ? 1 : 0

  account_id = var.tunnel.account_id
  tunnel_id  = cloudflare_tunnel.this.id

  config {
    origin_request {
      origin_server_name = var.origin_server_name
    }
    dynamic "ingress_rule" {
      for_each = var.ingress_rule
      content {
        hostname = ingress_rule.value.hostname
        service  = ingress_rule.value.service
      }
    }
    ingress_rule { service = "http_status:404" }
  }
}
