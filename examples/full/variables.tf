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

variable "admin_cidrs" {
  description = "IPv4 or IPv6 CIDRs allowed to reach SSH on the main example server."
  type        = list(string)
}

variable "image_selector" {
  description = "Labels selecting an existing available x86 snapshot, for example purpose=server-example."
  type        = string
}

variable "iso" {
  description = "Optional ISO name or ID to mount on the main server. Null boots the selected OS normally."
  type        = string
  default     = null
}

variable "rescue" {
  description = "Optional rescue system for the main server, for example linux64. Null uses a normal boot."
  type        = string
  default     = null
}
