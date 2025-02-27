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
    "mkdir -p /etc/nginx/conf.d",
  ]

  # Generate nginx configuration commands for each site
  config_commands = [for site in var.proxy_sites :
    "cat > /etc/nginx/conf.d/${site.domain}.conf << 'EOL'\nserver {\n  listen 80;\n  server_name ${site.domain} ${site.aliases != null ? join(" ", site.aliases) : ""};\n\n  location / {\n    proxy_pass ${site.target};\n    proxy_set_header Host $host;\n    proxy_set_header X-Real-IP $remote_addr;\n    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n    proxy_set_header X-Forwarded-Proto $scheme;\n  }\n}\nEOL"
  ]

  # Combine all commands
  all_commands = concat(local.base_commands, local.config_commands, ["nginx -t", "systemctl restart nginx"])
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
