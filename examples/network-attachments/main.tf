resource "hcloud_network" "private" {
  name     = "server-private"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "private" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

module "server" {
  source = "../.."

  name               = "network-attachments"
  type               = "cx23"
  image              = "ubuntu-24.04"
  cloud_init_enabled = false
  network_attachments = {
    app = {
      subnet_id = hcloud_network_subnet.private.id
      ip        = "10.0.1.2"
      alias_ips = ["10.0.1.3"]
    }
  }
}
