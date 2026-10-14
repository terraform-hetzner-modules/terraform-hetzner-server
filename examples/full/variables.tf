variable "hcloud_token" {
  type        = string
  sensitive   = true
  default     = null
  description = "The API token for Hetzner Cloud."
}

variable "ssh_public_keys" {
  type        = list(string)
  description = "Public keys for the example admin account. Supply at least one to enable SSH access."
  validation {
    condition     = length(var.ssh_public_keys) > 0
    error_message = "Supply at least one SSH public key."
  }
}
