terraform {
  required_version = ">= 1.7"
  required_providers {
    hcloud = { source = "hetznercloud/hcloud", version = "~> 1.70" }
  }
}

resource "terraform_data" "network" {
  input = { network_id = 11, subnet_id = "12-10.1.1.0/24" }
}

module "subject" {
  source             = "../../.."
  name               = "computed-network-attachments"
  type               = "cx23"
  image              = "123"
  location           = null
  cloud_init_enabled = false
  network_attachments = {
    app     = { network_id = terraform_data.network.output.network_id }
    storage = { subnet_id = terraform_data.network.output.subnet_id }
  }
}

output "attachment_keys" {
  value       = keys(module.subject.network_attachments)
  description = "Keys remain known when provider identifiers are computed."
}
