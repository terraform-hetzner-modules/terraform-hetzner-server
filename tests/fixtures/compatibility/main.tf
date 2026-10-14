terraform {
  required_version = ">= 1.7"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.70"
    }
  }
}

variable "expected_rendered" {
  type        = string
  description = "Legacy payload supplied by the setup run for test assertions."
  sensitive   = true
}

module "current" {
  source   = "../../.."
  name     = "compatibility"
  type     = "cx23"
  image    = "123"
  location = null
}

output "matches_legacy" {
  value       = module.current.cloud_init_rendered == var.expected_rendered
  description = "Whether the default cloud-init payload matches the setup run."
  sensitive   = true
}
