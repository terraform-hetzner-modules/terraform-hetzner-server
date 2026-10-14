module "hetzner_server_example" {
  source = "../.."

  name     = "example-server"
  type     = "cx23"
  image    = "ubuntu-24.04"
  location = "nbg1"

  networking = {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
