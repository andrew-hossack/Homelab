output "ha_address" {
  description = "Web address for home assistant; eg. http://10.9.6.123:8123"
  value       = "http://${split("/", var.ipv4_cidr)[0]}:8123"
}
