# TODO - Ref: https://www.khanhph.com/install-proxmox-kubernetes/


# module "tailscale_container" {
#   source          = "../container_template"
#   container_name  = var.container_name
#   password        = var.password
#   ssh_private_key = var.ssh_private_key
#   ssh_public_key  = var.ssh_public_key
#   ipv4_cidr       = var.ipv4_cidr
#   gateway         = var.gateway
#   provisioning_commands = [
#     <<-EOF
#     echo 'todo'
#     EOF
#   ]
# }


locals {
  install_script = file("${path.module}/scripts/create-vm-template.sh")
  commands = [
      "chmod +x /tmp/create-vm-template.sh",
      "/tmp/create-vm-template.sh",
      "rm /tmp/create-vm-template.sh",
      "qm clone 9000 9001 --name ${var.gateway_vm_name} --full true",
      "qm set 9001 --sshkey /root/.ssh/id_rsa.pub",
      "qm set 9001 --net0 virtio,bridge=vmbr0 --ipconfig0 ip=${local.ipv4_cidr},gw=${local.gateway}",
      # Kubernetes IP is set corresponding to the network interface vmbr1. See README.
      "qm set 9001 --net1 virtio,bridge=vmbr1 --ipconfig1 ip=10.0.1.2/24,gw=10.0.1.1",
      "qm set 9001 --onboot 1",
      "qm start 9001",
    ]
  ipv4_cidr = var.ipv4_cidr
  gateway = var.gateway
}

resource "null_resource" "update_cluster_config" {
  triggers = {
    install_script = local.install_script
    commands = sha256(join(",", local.commands))
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key)
    host        = var.cluster_ip
    timeout     = "60s"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/create-vm-template.sh"
    destination = "/tmp/create-vm-template.sh"
  }

  provisioner "remote-exec" {
    inline = local.commands
  }
}

