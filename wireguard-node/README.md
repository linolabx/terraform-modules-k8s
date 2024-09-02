# wireguard-node

create necessary data for a wireguard node

## Usage

```hcl
module "foo_node" {
  source = "github.com/linolabx/terraform-modules-k8s//wireguard-node"

  vault_mount = var.vault_mount
  vault_name  = "path/to/node/info"

  domain = "foo.bar.com"
  ip     = "1.2.3.4"

  save_config_to = "path/to/node/config/wg0"

  wg_address   = ["2.3.4.5/24"]
  wg_post_up   = "iptables -A FORWARD -i %i -j ACCEPT"
  wg_post_down = "iptables -D FORWARD -i %i -j ACCEPT"
}
```

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_vault"></a> [vault](#requirement_vault)             | ~> 3.0  |
| <a name="requirement_wireguard"></a> [wireguard](#requirement_wireguard) | 0.3.1   |

## Providers

| Name                                                               | Version |
| ------------------------------------------------------------------ | ------- |
| <a name="provider_vault"></a> [vault](#provider_vault)             | ~> 3.0  |
| <a name="provider_wireguard"></a> [wireguard](#provider_wireguard) | 0.3.1   |

## Modules

No modules.

## Resources

| Name                                                                                                                          | Type     |
| ----------------------------------------------------------------------------------------------------------------------------- | -------- |
| [vault_kv_secret_v2.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2)         | resource |
| [wireguard_asymmetric_key.this](https://registry.terraform.io/providers/OJFord/wireguard/0.3.1/docs/resources/asymmetric_key) | resource |

## Inputs

| Name                                                                  | Description | Type           | Default | Required |
| --------------------------------------------------------------------- | ----------- | -------------- | ------- | :------: |
| <a name="input_domain"></a> [domain](#input_domain)                   | n/a         | `string`       | `null`  |    no    |
| <a name="input_gen_config"></a> [gen_config](#input_gen_config)       | n/a         | `bool`         | `false` |    no    |
| <a name="input_ip"></a> [ip](#input_ip)                               | n/a         | `string`       | `null`  |    no    |
| <a name="input_port"></a> [port](#input_port)                         | n/a         | `number`       | `24737` |    no    |
| <a name="input_vault_mount"></a> [vault_mount](#input_vault_mount)    | n/a         | `string`       | n/a     |   yes    |
| <a name="input_vault_name"></a> [vault_name](#input_vault_name)       | n/a         | `string`       | n/a     |   yes    |
| <a name="input_wg_address"></a> [wg_address](#input_wg_address)       | n/a         | `list(string)` | `null`  |    no    |
| <a name="input_wg_dns"></a> [wg_dns](#input_wg_dns)                   | n/a         | `list(string)` | `null`  |    no    |
| <a name="input_wg_mtu"></a> [wg_mtu](#input_wg_mtu)                   | n/a         | `number`       | `null`  |    no    |
| <a name="input_wg_name"></a> [wg_name](#input_wg_name)                | n/a         | `string`       | `null`  |    no    |
| <a name="input_wg_post_down"></a> [wg_post_down](#input_wg_post_down) | n/a         | `string`       | `null`  |    no    |
| <a name="input_wg_post_up"></a> [wg_post_up](#input_wg_post_up)       | n/a         | `string`       | `null`  |    no    |
| <a name="input_wg_pre_down"></a> [wg_pre_down](#input_wg_pre_down)    | n/a         | `string`       | `null`  |    no    |
| <a name="input_wg_pre_up"></a> [wg_pre_up](#input_wg_pre_up)          | n/a         | `string`       | `null`  |    no    |
| <a name="input_wg_table"></a> [wg_table](#input_wg_table)             | n/a         | `string`       | `null`  |    no    |

## Outputs

| Name                                                                 | Description |
| -------------------------------------------------------------------- | ----------- |
| <a name="output_config_file"></a> [config_file](#output_config_file) | n/a         |
| <a name="output_domain"></a> [domain](#output_domain)                | n/a         |
| <a name="output_endpoint"></a> [endpoint](#output_endpoint)          | n/a         |
| <a name="output_ip"></a> [ip](#output_ip)                            | n/a         |
| <a name="output_port"></a> [port](#output_port)                      | n/a         |
| <a name="output_privatekey"></a> [privatekey](#output_privatekey)    | n/a         |
| <a name="output_publickey"></a> [publickey](#output_publickey)       | n/a         |
