terraform {
  required_version = ">= 1.7"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.70"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
