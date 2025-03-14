variable "gateway_vm_name" {
  description = "Name of the bastion VM"
}
variable "ipv4_cidr" {
  description = "Static IPv4 address for the instance in CIDR format"
}
variable "advertise_routes" {
    description = "Similar to IPv4 but at the 0 address; eg. 192.168.0.0/24"
}
variable "ssh_private_key" {
  description = "Local filepath to key from terraform local machine"
}
variable "ssh_public_key" {
  description = "Local filepath to key from terraform local machine"
}

variable "cluster_ip" {
  description = "IPv4 address for the cluster"
  
}
variable "gateway" {
  description = "Gateway address"
}