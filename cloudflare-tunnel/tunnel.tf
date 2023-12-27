variable "tunnel" {
  type = object({
    account_id = string
    name       = string
  })
}

resource "random_password" "tunnel_secret" { length = 64 }

resource "cloudflare_tunnel" "this" {
  account_id = var.tunnel.account_id
  name       = var.tunnel.name
  secret     = base64sha256(random_password.tunnel_secret.result)
  config_src = "cloudflare"
}

output "tunnel_id" {
  value = cloudflare_tunnel.this.id
}
