variable "server_id" {
  description = "ID of the source server. Changing this replaces the snapshot."
  type        = number
}

variable "description" {
  description = "Description of the snapshot. Null uses the provider default."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels attached to the snapshot."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "timeouts" {
  description = "Operation timeouts. Omitted create uses the provider's 90-minute default."
  type        = object({ create = optional(string) })
  default     = {}
  nullable    = false
}
