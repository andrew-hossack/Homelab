variable "node" {
  default = "proxmox"
}
variable "os_template" {
  description = "OS template to use"
  default     = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
}
variable "container_name" {
  description = "Name for the LXC"
}
variable "password" {
  description = "Password for the container"
}
variable "memory" {
  default = "512"
  description = "A number containing the amount of RAM to assign to the container (in MB)."
}
variable "ipv4_cidr" {
  description = "Static IPv4 address for the instance"
}
variable "gateway" {
  default = "10.9.6.1"
}
variable "dns_address" {
  description = "DNS address to use"
  default = "1.1.1.1"
}
variable "storage_size" {
  description = "Storage size to assign"
  default     = "8G"
}
variable "storage_fs" {
  default = "local-lvm"
}

variable "cores" {
  default = 2
}

variable "provisioning_commands" {
  description = "List of commands to run during provisioning"
  type        = list(string)
}
variable "ssh_public_key" {
  description = "Local filepath to key from terraform local machine"
}
variable "ssh_private_key" {
  description = "Local filepath to key from terraform local machine"
}