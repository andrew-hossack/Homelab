# Home Assistant LXC Installer

## Example

```
module "home-assistant-lxc" {
  source          = "./modules/home-assistant-lxc"
  container_name  = "home-assistant"
  ipv4_cidr       = "10.9.6.104/24"
  cluster_ip      = local.cluster_ip
  gateway_cidr    = "${local.gateway}/24"
  password        = local.container_default_password
  ssh_private_key = local.ssh_private_key
  ssh_public_key  = local.ssh_public_key
}
```