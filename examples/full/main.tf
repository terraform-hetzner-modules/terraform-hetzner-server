resource "hcloud_network" "example" {
  name     = "server-example"
  ip_range = "10.0.0.0/16"
}
resource "hcloud_network_subnet" "example" {
  network_id   = hcloud_network.example.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
module "hetzner_server_example" {
  source     = "../.."
  name       = "example-server"
  type       = "cx23"
  image      = "ubuntu-24.04"
  location   = "nbg1"
  networking = { ipv4_enabled = true, ipv6_enabled = true }
  private_networks = {
    app = { subnet_id = hcloud_network_subnet.example.id }
  }
  placement_group = { enabled = true }
  timeouts        = { create = "20m" }
  cloud_init = {
    config = local.cloud_init_config
    parts = [{
      filename     = "bootstrap.sh"
      content_type = "text/x-shellscript"
      content      = "#!/bin/sh\nprintf 'Provisioned by Terraform\\n' > /etc/motd\n"
    }]
  }
}
