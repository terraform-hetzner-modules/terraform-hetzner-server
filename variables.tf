variable "name" {
  type        = string
  description = "The name given to the new server. Must be unique per Hetzner project and a valid hostname in accordance with RFC 1123."
}

variable "type" {
  type        = string
  description = "The type of server to create. See the output of Hetzner's CLI hcloud command 'server-type list' for reference."
}

variable "image" {
  type        = string
  description = "The OS image to use for the new server."
}

variable "location" {
  type        = string
  description = "The data center location to create the new machine in. Can be one of the following: 'nbg1', 'fsn1', 'hel1', 'ash' or 'hil'. Default is 'fsn1'."
  default     = "fsn1"
}

variable "ssh_keys" {
  type        = list(string)
  description = "A list of SSH key names or IDs, which should be injected into the server at creation. None are injected by default."
  default     = []
}

variable "keep_disk" {
  type        = bool
  description = "Whether or not the disk should be kept when scaling servers. This allows for downgrades later down the line."
  default     = false
}

variable "iso" {
  type        = string
  description = "The name or ID of an ISO image to mount into the machine on creation."
  default     = null
}

variable "rescue" {
  type        = string
  description = "If specified the system will boot into the given rescue system to allow for easy installation of custom operating systems."
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "A map of label to attach to the server on creation."
  default     = {}
}

variable "backups" {
  type        = bool
  description = "Whether or not to enable Hetzner's automatic backups."
  default     = false
}

variable "firewall_ids" {
  type        = list(string)
  description = "A list of firewall IDs that should be attached to the server on creation."
  default     = []
}

variable "ignore_remote_firewall_ids" {
  type        = bool
  description = "Ignore any updates to the firewall_ids argument."
  default     = false
}

variable "networking" {
  type        = any
  description = "The networking settings to apply to the instance. Like whether IPv6 is enabled or not. By default both IPv4 and IPv6 are enabled. The IPv4 address may be manually or automatically assigned via Hetzner."
  default     = {}
}

variable "private_networks" {
  type        = any
  description = "The private networks to attach the server to on creation."
  default     = []
}

# variable "placement_group_id" {
#   type        = string
#   description = "The ID of a placement group to attach to the server."
#   default     = null
# }

variable "enable_protection" {
  type        = bool
  description = "Enable Hetzner's 'rebuild' and 'delete' protection."
  default     = false
}

variable "allow_deprecated_images" {
  type        = bool
  description = "Enable the use of deprecated images. NOTE: Deprecated images will be removed after three months."
  default     = false
}

variable "shutdown_before_deletion" {
  type        = bool
  description = "Shutdown the server gracefully before deleting it."
  default     = true
}

# -------------------------------------
# Custom Variables
# -------------------------------------

variable "create_server" {
  type        = bool
  description = "Whether or not to create a Server. This is true by default of course."
  default     = true
}

variable "placement_group" {
  type = object({
    enabled = bool
    name    = optional(string)
    type    = optional(string)
    labels  = optional(map(string))
  })
  default = {
    enabled = false
  }
  description = "Configuration for a placement group to be attached to the server."
}

variable "cloud_init" {
  type = object({
    gzip          = bool
    base64_encode = bool
    config        = any
  })
  description = "The cloud_init configuration to render the template with."
  default = {
    gzip          = true
    base64_encode = true
    config        = {}
  }
}
