variable "records" {
  type = map(object({
    zone_id = string
    name    = string
  }))
  default = {}
}

resource "cloudflare_record" "this" {
  for_each = var.records

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = "CNAME"
  value   = cloudflare_tunnel.this.cname
  proxied = true

  comment = var.tunnel.name
}
