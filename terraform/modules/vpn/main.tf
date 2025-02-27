module "tailscale_container" {
  source          = "../container_template"
  container_name  = var.container_name
  password        = var.password
  ssh_private_key = var.ssh_private_key
  ssh_public_key  = var.ssh_public_key
  ipv4_cidr       = var.ipv4_cidr
  gateway         = var.gateway
  provisioning_commands = [
    <<-EOF
    # Add Tailscale’s package signing key and repository:
    wget -qO /usr/share/keyrings/tailscale-archive-keyring.gpg https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg
    wget -qO /etc/apt/sources.list.d/tailscale.list https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list


    # Install Tailscale:
    apt-get update
    apt-get install tailscale -y
    # Advertise a device as exit node
    echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
    sysctl -p /etc/sysctl.d/99-tailscale.conf
    EOF
  ]
}

locals {
  container_id = split("/", module.tailscale_container.container_id)[2]
}

resource "null_resource" "update_cluster_config" {
  depends_on = [module.tailscale_container]
  triggers = {
    container_id = module.tailscale_container.container_id
  }


  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key)
    host        = var.cluster_ip
    timeout     = "60s"
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOF
      grep -qxF "lxc.cgroup2.devices.allow: c 10:200 rwm" /etc/pve/lxc/${local.container_id}.conf || echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >> /etc/pve/lxc/${local.container_id}.conf
      grep -qxF "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" /etc/pve/lxc/${local.container_id}.conf || echo "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> /etc/pve/lxc/${local.container_id}.conf
      pct reboot ${local.container_id}
    EOF
    ]
  }
}


resource "null_resource" "start_tailscale" {
  depends_on = [null_resource.update_cluster_config]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key)
    host        = split("/", module.tailscale_container.container_ip)[0]
    timeout     = "60s"
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOF
      # Advertise subnet route and start tailscale
      tailscale up --reset --advertise-routes=${var.advertise_routes} --advertise-exit-node --authkey=${var.tailscale_auth_key}
      EOF
    ]
  }
}


