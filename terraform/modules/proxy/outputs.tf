output "container_ip" {
  description = "IP address of the Nginx proxy container"
  value       = module.nginx_container.container_ip
}