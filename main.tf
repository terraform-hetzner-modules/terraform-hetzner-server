data "cloudinit_config" "cloud_config" {
  count         = local.render_cloud_init ? 1 : 0
  gzip          = var.cloud_init.gzip
  base64_encode = var.cloud_init.base64_encode
  boundary      = var.cloud_init.boundary

  dynamic "part" {
    for_each = local.cloud_init_parts
    content {
      filename     = part.value.filename
      content_type = part.value.content_type
      content      = part.value.content
      merge_type   = part.value.merge_type
    }
  }
}

data "hcloud_server_type" "current_type" {
  count = var.create_server ? 1 : 0
  name  = var.type
}

data "hcloud_image" "os" {
  count              = var.create_server ? 1 : 0
  id                 = local.image_id
  name               = local.image_id == null ? var.image : null
  with_architecture  = data.hcloud_server_type.current_type[0].architecture
  with_selector      = try(var.image_selector.with_selector, null)
  most_recent        = try(var.image_selector.most_recent, false)
  include_deprecated = try(var.image_selector.include_deprecated, false)
  with_status        = try(var.image_selector.with_status, null)

  lifecycle {
    precondition {
      condition     = (var.image != null) != (var.image_selector != null)
      error_message = "Specify exactly one of image (name or ID) and image_selector."
    }
  }
}

resource "hcloud_server" "current" {
  count = var.create_server ? 1 : 0

  name                       = var.name
  server_type                = var.type
  image                      = data.hcloud_image.os[0].id
  location                   = var.location
  user_data                  = var.user_data != null ? var.user_data : try(data.cloudinit_config.cloud_config[0].rendered, null)
  ssh_keys                   = var.ssh_keys
  keep_disk                  = var.keep_disk
  iso                        = var.iso
  rescue                     = var.rescue
  labels                     = var.labels
  backups                    = var.backups
  firewall_ids               = var.firewall_ids
  ignore_remote_firewall_ids = var.ignore_remote_firewall_ids
  placement_group_id         = var.placement_group.enabled ? module.placement_group[0].id : var.placement_group_id
  delete_protection          = var.enable_protection
  rebuild_protection         = var.enable_protection
  shutdown_before_deletion   = var.shutdown_before_deletion

  dynamic "public_net" {
    for_each = var.networking == null ? [] : [var.networking]
    content {
      ipv4         = public_net.value.ipv4
      ipv4_enabled = public_net.value.ipv4_enabled
      ipv6         = public_net.value.ipv6
      ipv6_enabled = public_net.value.ipv6_enabled
    }
  }
  dynamic "network" {
    for_each = local.private_networks
    content {
      alias_ips  = network.value.alias_ips
      ip         = network.value.ip
      network_id = network.value.network_id
      subnet_id  = network.value.subnet_id
    }
  }
  timeouts {
    create = var.timeouts.create
  }
  lifecycle {
    # SSH keys are injected only at creation. Retain v1 behavior to avoid replacement.
    ignore_changes = [ssh_keys]
    precondition {
      condition     = !var.placement_group.enabled || var.placement_group_id == null
      error_message = "Choose an existing placement_group_id or enable a managed placement_group, not both."
    }
    precondition {
      condition     = length(local.legacy_private_network) == 0 || length(var.private_networks) == 0
      error_message = "Use either private_network or private_networks."
    }
    precondition {
      condition     = length(local.private_networks) == 0 || length(var.network_attachments) == 0
      error_message = "Use inline private_network/private_networks or separate network_attachments, not both."
    }
    precondition {
      condition     = alltrue([for n in local.private_networks : n.network_id != null || n.subnet_id != null])
      error_message = "Each private network needs a network_id or subnet_id."
    }
    precondition {
      condition     = var.location == null ? true : contains(data.hcloud_server_type.current_type[0].locations[*].name, var.location)
      error_message = "The chosen server type does not support this location."
    }
  }
}

module "placement_group" {
  source = "./modules/placement-group"
  count  = var.create_server && var.placement_group.enabled ? 1 : 0
  name   = coalesce(var.placement_group.name, var.name)
  type   = var.placement_group.type
  labels = var.placement_group.labels
}

resource "hcloud_server_network" "current" {
  for_each = var.create_server ? var.network_attachments : {}

  server_id  = hcloud_server.current[0].id
  network_id = each.value.network_id
  subnet_id  = each.value.subnet_id
  ip         = each.value.ip
  alias_ips  = each.value.alias_ips
}
