terraform {
  required_version = ">= 1.7"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.4"
    }
  }
}

# Render the original v1 payload independently of the module under test.
data "cloudinit_config" "legacy" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = yamlencode({})
  }
}

output "rendered" {
  value       = data.cloudinit_config.legacy.rendered
  description = "Original v1 default cloud-init payload."
}
