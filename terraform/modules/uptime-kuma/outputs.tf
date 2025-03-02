output "container_ip" {
  description = "IP address of the Nginx proxy container"
  value       = split("/",module.uptime_kuma_lxc.container_ip)[0]
}