terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = "0.3.1"
    }
  }
}

variable "vault_mount" { type = string }
variable "vault_name" { type = string }

variable "domain" {
  type    = string
  default = null
}
variable "ip" {
  type    = string
  default = null
}
variable "port" {
  type    = number
  default = 24737
}

resource "wireguard_asymmetric_key" "this" {}

locals { endpoint = var.domain != null ? "${var.domain}:${var.port}" : (var.ip != null ? "${var.ip}:${var.port}" : null) }

resource "vault_kv_secret_v2" "this" {
  mount = var.vault_mount
  name  = var.vault_name

  delete_all_versions = true

  data_json = jsonencode({
    privatekey = wireguard_asymmetric_key.this.private_key
    publickey  = wireguard_asymmetric_key.this.public_key
    port       = var.port
    domain     = var.domain
    ip         = var.ip
    endpoint   = local.endpoint
  })
}

output "vault_name" { value = var.vault_name }

output "privatekey" {
  sensitive = true
  value     = wireguard_asymmetric_key.this.private_key
}
output "publickey" { value = wireguard_asymmetric_key.this.public_key }
output "port" { value = var.port }
output "domain" { value = var.domain }
output "ip" { value = var.ip }
output "endpoint" { value = local.endpoint }
