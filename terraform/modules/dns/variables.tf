variable "container_name" {
  description = "Name for the LXC"
  default     = "pihole-dns"
}

variable "password" {
  description = "Password for the container"
  sensitive   = true
}

variable "ipv4_cidr" {
  description = "Static IPv4 address for the instance in CIDR format"
}


variable "pihole_password" {
}