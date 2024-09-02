variable "save_config_to" {
  type    = string
  default = null
}
variable "gen_config" {
  type    = bool
  default = false
}

variable "wg_name" {
  type    = string
  default = null
}
variable "wg_address" {
  type    = list(string)
  default = null
}
variable "wg_dns" {
  type    = list(string)
  default = null
}
variable "wg_table" {
  type    = string
  default = null
}
variable "wg_mtu" {
  type    = number
  default = null
}
variable "wg_pre_up" {
  type    = string
  default = null
}
variable "wg_post_up" {
  type    = string
  default = null
}
variable "wg_pre_down" {
  type    = string
  default = null
}
variable "wg_post_down" {
  type    = string
  default = null
}

locals {
  config = var.save_config_to != null || var.gen_config ? join("\n", compact([
    "[Interface]",
    var.wg_name == null ? null : "# Name = ${var.wg_name}",
    "ListenPort = ${var.port}",
    "PrivateKey = ${wireguard_asymmetric_key.this.private_key}",
    var.wg_address == null ? null : "Address = ${join(", ", var.wg_address)}",
    var.wg_dns == null ? null : "DNS = ${join(", ", var.wg_dns)}",
    var.wg_table == null ? null : "Table = ${var.wg_table}",
    var.wg_mtu == null ? null : "MTU = ${var.wg_mtu}",
    var.wg_pre_up == null ? null : "PreUp = ${var.wg_pre_up}",
    var.wg_post_up == null ? null : "PostUp = ${var.wg_post_up}",
    var.wg_pre_down == null ? null : "PreDown = ${var.wg_pre_down}",
    var.wg_post_down == null ? null : "PostDown = ${var.wg_post_down}",
  ])) : null
}

output "config" {
  sensitive = true
  value     = local.config
}

resource "vault_kv_secret_v2" "config" {
  count = var.save_config_to != null ? 1 : 0

  mount = var.vault_mount
  name  = var.save_config_to

  delete_all_versions = true

  data_json = jsonencode({ content = local.config })
}

output "vault_config_name" { value = var.save_config_to }
