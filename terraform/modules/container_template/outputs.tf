output "container_ip" {
  description = "IP address of the container"
  value       = proxmox_lxc.container.network[0].ip
}
output "container_id" {
  description = "ID of the container"
  value = proxmox_lxc.container.id
}