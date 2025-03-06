locals {
  install_script = file("${path.module}/scripts/homeassistant-install.sh")
}

resource "null_resource" "update_cluster_config" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key)
    host        = var.cluster_ip
    timeout     = "60s"
    # Don't specify script_path here
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
      "NETWORK_CIDR='${var.ipv4_cidr}' GATEWAY_ADDRESS='${split("/", var.gateway_cidr)[0]}' CT_PASSWORD='${nonsensitive(var.password)}' /tmp/homeassistant-install.sh",
      "rm /tmp/homeassistant-install.sh"
    ]
  }
}
