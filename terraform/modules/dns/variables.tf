variable "container_name" {
  description = "Name for the LXC"
  default     = "pihole-dns"
}

variable "password" {
  description = "Password for the container"
  sensitive   = true
}

variable "ipv4_cidr" {
  description = "Static IPv4 address for the instance in CIDR format (10.9.6.x/24)"
}


variable "pihole_password" {
}
variable "ssh_public_key" {
  description = "Local filepath to key from terraform local machine"
}
variable "ssh_private_key" {
  description = "Local filepath to key from terraform local machine"
}
variable "gateway" {
  description = "Gateway address eg. 10.9.6.1"
}

variable "custom_dns_hosts" {
  description = "A list of custom DNS hostnames and their corresponding IP addresses"
  type = list(object({
    hostname = string
    proxy    = string
  }))
}
