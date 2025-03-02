terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

locals {
  base_commands = [
    "apt-get update",
    "apt-get install -y nginx",
    "systemctl enable nginx",
    "mkdir -p /etc/nginx/sites-available",
    "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-custom.key -out /etc/ssl/certs/nginx-custom.crt -subj '/C=US/ST=UT/L=SLC/O=NA/OU=NA/CN=NA'"
  ]

  config_commands = [for site in var.proxy_sites :
    "echo '${templatefile("${path.module}/sites/${site.template}", {
      target = site.target
      hostname = site.hostname
    })}' > /etc/nginx/sites-available/${site.template}"
  ]

  symlink_commands = [for site in var.proxy_sites :
    "ln -sf /etc/nginx/sites-available/${site.template} /etc/nginx/sites-enabled/"
  ]

  restart_commands = [
    "nginx -t",
    "systemctl restart nginx"
  ]

  all_commands = concat(local.base_commands, local.config_commands, local.symlink_commands, local.restart_commands)
}

module "nginx_container" {
  source                = "../container_template"
  node                  = var.node
  os_template           = var.os_template
  container_name        = var.container_name
  password              = var.password
  ipv4_cidr             = var.ipv4_cidr
  dns_address           = var.dns_address
  provisioning_commands = local.all_commands
  ssh_private_key       = var.ssh_private_key
  ssh_public_key        = var.ssh_public_key
  gateway               = var.gateway
}
