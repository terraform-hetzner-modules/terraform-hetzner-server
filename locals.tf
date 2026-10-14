locals {
  legacy_private_network = var.private_network == null ? {} : (
    var.private_network.network_id == null && var.private_network.subnet_id == null && var.private_network.ip == null && length(var.private_network.alias_ips) == 0 ? {} : { default = var.private_network }
  )
  private_networks  = merge(local.legacy_private_network, var.private_networks)
  image_id          = try(tonumber(var.image), null)
  render_cloud_init = var.create_server && var.cloud_init_enabled
  cloud_init_parts = concat(var.cloud_init.include_config ? [{
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = yamlencode(var.cloud_init.config)
    merge_type   = null
  }] : [], var.cloud_init.parts)
}
