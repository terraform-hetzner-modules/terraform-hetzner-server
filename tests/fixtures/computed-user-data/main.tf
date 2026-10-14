terraform {
  required_version = ">= 1.7"
  required_providers {
    hcloud = { source = "hetznercloud/hcloud", version = "~> 1.70" }
  }
}
resource "terraform_data" "payload" { input = "#cloud-config\n{}\n" }
module "subject" {
  source    = "../../.."
  name      = "computed-user-data"
  type      = "cx23"
  image     = "123"
  location  = null
  user_data = terraform_data.payload.output
}
