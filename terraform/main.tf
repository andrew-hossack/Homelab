terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

locals {
  api_url = "https://10.9.6.162:8006/api2/json"
  container_default_password = var.container_default_password
  ssh_private_key = "~/.ssh/id_rsa"
  ssh_public_key = "~/.ssh/id_rsa.pub"
  network_cidr = "10.9.6.0/24"
}

provider "proxmox" {
  pm_api_url          = local.api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
}

module "proxy" {
  source = "./modules/proxy"
  
  container_name = "nginx-proxy"
  ipv4_cidr      = "10.9.6.100/24"
  password       = local.container_default_password
  ssh_private_key = local.ssh_private_key
  ssh_public_key = local.ssh_public_key
  proxy_sites = [
    {
      domain  = "dashboard.example.com"
      target  = "http://192.168.1.101:3000"
    }
  ]
}

module "dns" {
  source = "./modules/dns"
  container_name = "pihole-dns"
  ipv4_cidr      = "10.9.6.101/24"
  password       = local.container_default_password
  pihole_password = local.container_default_password
  ssh_private_key = local.ssh_private_key
  ssh_public_key = local.ssh_public_key
}

module "vpn" {
  source = "./modules/vpn"
  container_name = "tailscale-vpn"
  ipv4_cidr = "10.9.6.102/24"
  password = local.container_default_password
  advertise_routes = local.network_cidr
  tailscale_auth_key = var.tailscale_auth_key
  ssh_private_key = local.ssh_private_key
  ssh_public_key = local.ssh_public_key
}


# module "home_assistant" {
#   source = "./modules/home_assistant"
# }

# module "uptime_kuma" {
#   source = "./modules/uptime_kuma"
# }