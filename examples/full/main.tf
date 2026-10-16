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

resource "hcloud_primary_ip" "example" {
  for_each    = toset(["ipv4", "ipv6"])
  name        = "server-example-${each.key}"
  type        = each.key
  location    = "nbg1"
  auto_delete = false
}

resource "hcloud_ssh_key" "admin" {
  for_each   = { for index, key in var.ssh_public_keys : tostring(index) => key }
  name       = "server-example-admin-${each.key}"
  public_key = each.value
}

resource "hcloud_firewall" "example" {
  name = "server-example"
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.admin_cidrs
  }
}

# Every root input is shown here. Mutually exclusive alternatives follow below.
module "hetzner_server_example" {
  source                     = "../.."
  name                       = "example-server"
  type                       = "cx23"
  image                      = "ubuntu-24.04"
  image_selector             = null
  location                   = "nbg1"
  ssh_keys                   = [for key in hcloud_ssh_key.admin : key.id]
  keep_disk                  = true
  iso                        = var.iso
  rescue                     = var.rescue
  labels                     = { environment = "example", role = "worker" }
  backups                    = true
  firewall_ids               = [hcloud_firewall.example.id]
  ignore_remote_firewall_ids = false
  enable_protection          = false
  allow_deprecated_images    = false # Compatibility input; no effect in the current provider.
  shutdown_before_deletion   = true
  create_server              = true
  networking = {
    ipv4         = hcloud_primary_ip.example["ipv4"].id
    ipv4_enabled = true
    ipv6         = hcloud_primary_ip.example["ipv6"].id
    ipv6_enabled = true
  }
  private_network = null
  private_networks = {
    app = {
      network_id = hcloud_network.example.id
      subnet_id  = hcloud_network_subnet.example.id
      ip         = "10.0.1.10"
      alias_ips  = ["10.0.1.11"]
    }
  }
  network_attachments = {}
  placement_group_id  = null
  placement_group = {
    enabled = true
    name    = "example-server-spread"
    type    = "spread"
    labels  = { environment = "example" }
  }
  timeouts           = { create = "20m" }
  cloud_init_enabled = true
  user_data          = null
  cloud_init = {
    gzip           = true
    base64_encode  = true
    boundary       = "MIMEBOUNDARY"
    include_config = true
    config         = local.cloud_init_config
    parts = [{
      filename     = "timezone.yaml"
      content_type = "text/cloud-config"
      content      = "#cloud-config\n${yamlencode({ timezone = "Etc/UTC" })}"
      merge_type   = "list(append)+dict(no_replace,recurse_list)"
    }]
  }
}

module "placement_group" {
  source = "../../modules/placement-group"
  name   = "example-alternative-spread"
  type   = "spread"
  labels = { environment = "example" }
}

# Alternative: image discovery, an existing group, raw user data, and the legacy
# single-network input. The selected snapshot must already exist in this project.
module "selected_image" {
  source = "../.."
  name   = "example-selected-image"
  type   = "cx23"
  image  = null
  image_selector = {
    with_selector      = var.image_selector
    most_recent        = true
    include_deprecated = false
    with_status        = ["available"]
  }
  location           = "nbg1"
  placement_group_id = module.placement_group.id
  private_network = {
    network_id = hcloud_network.example.id
    subnet_id  = hcloud_network_subnet.example.id
    ip         = "10.0.1.20"
    alias_ips  = ["10.0.1.21"]
  }
  cloud_init_enabled = false
  user_data          = "#cloud-config\n${yamlencode(local.cloud_init_config)}"
}

# Alternative: attachments made after server creation. Public networking remains
# available during provisioning, before the private attachment has completed.
module "separate_attachment" {
  source             = "../.."
  name               = "example-separate-attachment"
  type               = "cx23"
  image              = "ubuntu-24.04"
  location           = "nbg1"
  cloud_init_enabled = true
  cloud_init         = { config = local.cloud_init_config }
  network_attachments = {
    app = {
      network_id = null # Use network_id instead of subnet_id for network-level selection.
      subnet_id  = hcloud_network_subnet.example.id
      ip         = "10.0.1.30"
      alias_ips  = ["10.0.1.31"]
    }
  }
}
