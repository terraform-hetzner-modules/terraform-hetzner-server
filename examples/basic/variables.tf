variable "hcloud_token" {
  type        = string
  sensitive   = true
  default     = null
  description = "The API token for Hetzner Cloud."
}
