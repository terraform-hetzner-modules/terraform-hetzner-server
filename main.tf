# ------------------------------------------
# Cloud-Init configuration
# ------------------------------------------

data "cloudinit_config" "cloud_config" {
  gzip          = var.cloud_init["gzip"]
  base64_encode = var.cloud_init["base64_encode"]

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = yamlencode(var.cloud_init["config"])
  }
}

# ------------------------------------------
# Server Data Sources
# ------------------------------------------

data "hcloud_images" "remote_images" {
  with_architecture = [local.arch]
}

data "hcloud_server_type" "current_type" {
  name = var.type
}

data "hcloud_datacenter" "current" {
  name = local.suffixed_datacenter
}

# ------------------------------------------
# Server Instance
# ------------------------------------------
resource "hcloud_server" "current" {
  count = var.create_server ? 1 : 0

  # General configuration
  name        = var.name
  server_type = var.type
  image       = data.hcloud_image.os.id
  location    = var.location
  user_data   = data.cloudinit_config.cloud_config.rendered
  ssh_keys    = try(var.ssh_keys, [])

  # Infrastructure configuration
  keep_disk                  = var.keep_disk
  iso                        = var.iso
  rescue                     = var.rescue
  labels                     = var.labels
  backups                    = var.backups
  firewall_ids               = var.firewall_ids
  ignore_remote_firewall_ids = var.ignore_remote_firewall_ids
  placement_group_id         = var.placement_group.enabled ? module.placement_group.id : null

  # Protections
  delete_protection  = var.enable_protection
  rebuild_protection = var.enable_protection

  # Shutdown & Initialization
  allow_deprecated_images  = var.allow_deprecated_images
  shutdown_before_deletion = var.shutdown_before_deletion

  dynamic "public_net" {
    for_each = var.networking != {} ? [1] : []

    content {
      ipv4         = try(var.networking["ipv4"], null)
      ipv4_enabled = try(var.networking["ipv4_enabled"], true)
      ipv6         = try(var.networking["ipv6"], null)
      ipv6_enabled = try(var.networking["ipv6_enabled"], true)
    }
  }

  dynamic "network" {
    for_each = var.private_networks

    content {
      alias_ips  = try(network.value["alias_ips"], [""])
      ip         = try(network.value["ip"], null)
      network_id = try(network.value["network_id"], null)
    }
  }

  lifecycle {
    ignore_changes = [ssh_keys]

    precondition {
      condition     = contains(data.hcloud_images.remote_images.images[*].name, var.image)
      error_message = "Hetzner Cloud does not have your requested OS image: '${var.image}'. Please be sure to create a snapshot of a custom image first, or upload the custom image manually."
    }

    precondition {
      condition     = contains(data.hcloud_datacenter.current.supported_server_type_ids, data.hcloud_server_type.current_type.id)
      error_message = "The Hetzner Cloud location you chose does not support the server type you chose! Please switch to another server type or location to continue."
    }
  }
}

module "placement_group" {
  source = "./modules/placement-group"
  count  = var.placement_group.enabled ? 1 : 0

  name   = var.placement_group.name
  type   = var.placement_group.type
  labels = var.placement_group.labels
}
