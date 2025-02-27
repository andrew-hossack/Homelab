terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

# https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/resources/lxc.md
resource "proxmox_lxc" "container" {
  target_node     = var.node
  ostemplate      = var.os_template
  hostname        = var.container_name
  password        = var.password
  memory          = var.memory
  unprivileged    = true
  start           = true
  onboot          = true
  cores           = var.cores
  nameserver      = var.dns_address
  ssh_public_keys = file(var.ssh_public_key)

  rootfs {
    storage = var.storage_fs
    size    = var.storage_size
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = var.ipv4_cidr
    gw     = var.gateway
  }
}

resource "null_resource" "provisioning" {
  depends_on = [ proxmox_lxc.container ]
  triggers = {
    commands_hash = sha256(join(",", var.provisioning_commands))
    container_id  = proxmox_lxc.container.id
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key)
    host        = split("/", proxmox_lxc.container.network[0].ip)[0]
    timeout     = "60s"
  }

  provisioner "remote-exec" {
    inline = var.provisioning_commands
  }
}
