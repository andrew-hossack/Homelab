terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.api_url
  pm_api_token_id     = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure     = true
}

module "proxy" {
  source = "./modules/proxy"
  
  container_name = "nginx-proxy"
  password       = var.container_default_password
  ipv4_cidr      = "10.9.6.100/24"
  
  proxy_sites = [
    {
      domain  = "dashboard.example.com"
      target  = "http://192.168.1.101:3000"
    }
  ]
}

# output "proxy_ip" {
#   value = module.proxy.container_ip
# }

# module "vpn" {
#   source = "./modules/vpn"
# }

# module "dns" {
#   source = "./modules/dns"
# }


# module "home_assistant" {
#   source = "./modules/home_assistant"
# }

# module "uptime_kuma" {
#   source = "./modules/uptime_kuma"
# }
