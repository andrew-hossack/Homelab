output "container_id" {
    value = module.pihole_dns.container_id
}
output "container_ip" {
  description = "IP address of the Nginx proxy container"
  value       = split("/",module.pihole_dns.container_ip)[0]
}