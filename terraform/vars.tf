variable "pm_api_token_secret" {
  description = "Secret for proxmox terraform user. See /bootstrap readme."
}
variable "pm_api_token_id" {
  description = "ID for proxmox terraform user. See /bootstrap readme."
}

variable "container_default_password" {
  description = "Default password to use for containers. Username is root."
}
variable "tailscale_auth_key" {
  description = "Auth key for tailscale VPN. See https://login.tailscale.com/admin/settings/keys"
}
