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
  description = "OS image name or numeric image ID. Leave null when using image_selector."
  default     = null
}

variable "location" {
  type        = string
  description = "Location to create the server in. Null lets Hetzner choose a location; defaults to fsn1."
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
  type = object({
    ipv4         = optional(number)
    ipv4_enabled = optional(bool, true)
    ipv6         = optional(number)
    ipv6_enabled = optional(bool, true)
  })
  description = "Public networking, including existing primary IP IDs. Null uses the provider's dual-stack defaults."
  default     = null
}
variable "private_network" {
  type = object({
    network_id = optional(number)
    subnet_id  = optional(string)
    ip         = optional(string)
    alias_ips  = optional(list(string), [])
  })
  description = "Compatibility input for one private network. Prefer private_networks; do not use both. An empty object preserves the v1 no-network behavior."
  default     = null
}
variable "private_networks" {
  type = map(object({
    network_id = optional(number)
    subnet_id  = optional(string)
    ip         = optional(string)
    alias_ips  = optional(list(string), [])
  }))
  description = "Named inline private networks, attached during server creation. Mutually exclusive with network_attachments. Prefer subnet_id for explicit subnet selection and dependency ordering."
  default     = {}
  nullable    = false
  validation {
    condition     = alltrue([for n in var.private_networks : n.network_id != null || n.subnet_id != null])
    error_message = "Every private network requires network_id or subnet_id (or matching values for both)."
  }
}
variable "placement_group_id" {
  type        = number
  description = "Existing placement group ID. Mutually exclusive with placement_group.enabled."
  default     = null
}
variable "enable_protection" {
  type        = bool
  description = "Enable Hetzner's 'rebuild' and 'delete' protection."
  default     = false
}

# tflint-ignore: terraform_unused_declarations
variable "allow_deprecated_images" {
  type        = bool
  description = "Deprecated compatibility input: the provider no longer uses this flag. Use image_selector.include_deprecated for image discovery."
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
    enabled = optional(bool, false)
    name    = optional(string)
    type    = optional(string, "spread")
    labels  = optional(map(string), {})
  })
  default     = {}
  nullable    = false
  description = "Create a placement group. Its name defaults to the server name. No group is created when create_server is false."
}
variable "cloud_init" {
  type = object({
    gzip           = optional(bool, true)
    base64_encode  = optional(bool, true)
    boundary       = optional(string, "MIMEBOUNDARY")
    include_config = optional(bool, true)
    config         = optional(any, {})
    parts = optional(list(object({
      content      = string
      content_type = optional(string, "text/plain")
      filename     = optional(string)
      merge_type   = optional(string)
    })), [])
  })
  default     = {}
  nullable    = false
  description = "Cloud-init MIME configuration. The YAML config part is first, followed by parts in list order. Set include_config=false for custom parts only. Raw user_data takes precedence."
  validation {
    condition     = !var.cloud_init.gzip || var.cloud_init.base64_encode
    error_message = "base64_encode must be true when gzip is true."
  }
  validation {
    condition     = var.cloud_init.include_config || length(var.cloud_init.parts) > 0
    error_message = "Cloud-init requires a config part or at least one custom part. To omit user data, use cloud_init_enabled=false."
  }
}
variable "cloud_init_enabled" {
  type        = bool
  default     = true
  nullable    = false
  description = "Render cloud-init. Raw user_data takes precedence; set false to skip rendering. False with user_data=null sends no user data."
}
variable "user_data" {
  type        = string
  default     = null
  sensitive   = true
  description = "Raw user data, passed through unchanged and taking precedence over cloud_init."
}
variable "image_selector" {
  type = object({
    with_selector      = string
    most_recent        = optional(bool, true)
    include_deprecated = optional(bool, false)
    with_status        = optional(set(string), ["available"])
  })
  default     = null
  description = "Discover an image by labels, filtered to the server architecture. Mutually exclusive with image."
}
variable "timeouts" {
  type = object({
    create = optional(string)
  })
  default     = {}
  nullable    = false
  description = "Provider operation timeouts, for example { create = \"20m\" }. Null uses the provider default."
}

variable "network_attachments" {
  type = map(object({
    network_id = optional(number)
    subnet_id  = optional(string)
    ip         = optional(string)
    alias_ips  = optional(set(string), [])
  }))
  description = "Named separate server-network resources, attached after server creation. Use exactly one of network_id or subnet_id per entry. Mutually exclusive with inline private networks; empty when create_server is false."
  default     = {}
  nullable    = false
  validation {
    condition     = alltrue([for n in var.network_attachments : (n.network_id != null) != (n.subnet_id != null)])
    error_message = "Each network attachment requires exactly one of network_id or subnet_id."
  }
}
