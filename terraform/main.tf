terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

locals {
  cluster_ip                 = "10.9.6.162"
  gateway                    = "10.9.6.1"
  network_cidr               = "10.9.6.0/24"
  # Local ssh files from your local machine
  ssh_private_key            = "~/.ssh/id_rsa"
  ssh_public_key             = "~/.ssh/id_rsa.pub"
  container_default_password = var.container_default_password
}

provider "proxmox" {
  pm_api_url          = "https://${local.cluster_ip}:8006/api2/json"
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
}

module "vpn" {
  source             = "./modules/vpn"
  cluster_ip         = local.cluster_ip
  container_name     = "tailscale-vpn"
  ipv4_cidr          = "10.9.6.102/24"
  gateway            = local.gateway
  password           = local.container_default_password
  advertise_routes   = local.network_cidr
  tailscale_auth_key = var.tailscale_auth_key
  ssh_private_key    = local.ssh_private_key
  ssh_public_key     = local.ssh_public_key
}

module "uptime-kuma" {
  source = "./modules/uptime-kuma"
  container_name  = "uptime-kuma"
  ipv4_cidr       = "10.9.6.103/24"
  gateway         = local.gateway
  password        = local.container_default_password
  ssh_private_key = local.ssh_private_key
  ssh_public_key  = local.ssh_public_key
}

module "dns" {
  source          = "./modules/dns"
  container_name  = "pihole-dns"
  ipv4_cidr       = "10.9.6.101/24"
  gateway         = local.gateway
  password        = local.container_default_password
  pihole_password = local.container_default_password
  ssh_private_key = local.ssh_private_key
  ssh_public_key  = local.ssh_public_key
  custom_dns_hosts = [
    { hostname = "pihole.lan", proxy = "10.9.6.100" },
    { hostname = "proxmox.lan", proxy = "10.9.6.100" },
    { hostname = "status.lan", proxy = "10.9.6.100" },
  ]
}


module "proxy" {
  source          = "./modules/proxy"
  container_name  = "nginx-proxy"
  ipv4_cidr       = "10.9.6.100/24"
  gateway         = local.gateway
  password        = local.container_default_password
  ssh_private_key = local.ssh_private_key
  ssh_public_key  = local.ssh_public_key
  proxy_sites = [
    {
      template = "pihole.lan"
      target   = "http://${module.dns.container_ip}"
    },
    {
      template = "proxmox.lan"
      target   = "https://${local.cluster_ip}:8006"
    },
    {
      template = "status.lan"
      target   = "http://${module.uptime-kuma.container_ip}:3001"
    },
  ]
}

# module "home_assistant" {
#   source = "./modules/home_assistant"
# }


# drone io cicd

# kubernetes deployment
# haproxy
# consul