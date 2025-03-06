locals {
  install_script = file("${path.module}/scripts/homeassistant-install.sh")
}

resource "null_resource" "update_cluster_config" {
  connection {
    type            = "ssh"
    user            = "root"
    private_key     = file(var.ssh_private_key)
    host            = var.cluster_ip
    timeout         = "60s"
    agent           = false
    target_platform = "unix"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/homeassistant-install.sh"
    destination = "/tmp/homeassistant-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/homeassistant-install.sh",
      # "NETWORK_CIDR='${var.ipv4_cidr}' GATEWAY_ADDRESS='${split("/", var.gateway_cidr)[0]}' /tmp/homeassistant-install.sh",
      "/tmp/homeassistant-install.sh",
      "rm /tmp/homeassistant-install.sh"
    ]
  }
}
