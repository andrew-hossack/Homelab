variable "node" {
  description = "Proxmox node to deploy on"
  default     = "proxmox"
}

variable "os_template" {
  description = "OS template to use"
  default     = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
}

variable "container_name" {
  description = "Name for the LXC"
  default     = "nginx-proxy"
}

variable "password" {
  description = "Password for the container"
  sensitive   = true
}

variable "ipv4_cidr" {
  description = "Static IPv4 address for the instance in CIDR format"
}

variable "dns_address" {
  description = "DNS address to use"
  default     = "1.1.1.1"
}

variable "proxy_sites" {
  description = "List of sites to proxy"
  type = list(object({
    template  = string
    target  = string
    hostname =  string
  }))
}
variable "gateway" {
  description = "Gateway address"
}
variable "ssh_private_key" {
}

variable "ssh_public_key" {
}

