output "id" {
  value       = try(hcloud_server.current[0].id, null)
  description = "The internal Hetzner ID for the server."
}

output "name" {
  value       = try(hcloud_server.current[0].name, null)
  description = "The name of the Hetzner Cloud server."
}

output "server_type" {
  value       = try(hcloud_server.current[0].server_type, null)
  description = "The type of Hetzner Cloud server that was created."
}

output "image" {
  value       = try(hcloud_server.current[0].image, null)
  description = "The image used to create the Hetzner Cloud server."
}

output "location" {
  value       = try(hcloud_server.current[0].location, null)
  description = "The location of the Hetzner Cloud server."
}

output "datacenter" {
  value       = null
  description = "Deprecated compatibility output. Hetzner removed datacenters; use location. Always null."
}

output "backups" {
  value       = try(hcloud_server.current[0].backups, null)
  description = "The new server's automatic backup setting (boolean)."
}


output "iso" {
  value       = try(hcloud_server.current[0].iso, null)
  description = "The ID or name of the mounted ISO image."
}

output "ipv4_address" {
  value       = try(hcloud_server.current[0].ipv4_address, null)
  description = "The IPv4 address the server is configured with."
}

output "ipv6_address" {
  value       = try(hcloud_server.current[0].ipv6_address, null)
  description = "The IPv6 address the server is configured with."
}

output "ipv6_network" {
  value       = try(hcloud_server.current[0].ipv6_network, null)
  description = "The IPv6 network the server is configured in."
}

output "status" {
  value       = try(hcloud_server.current[0].status, null)
  description = "The current server status."
}

output "labels" {
  value       = try(hcloud_server.current[0].labels, null)
  description = "The labels attached to the new Hetzner Cloud server."
}

output "network" {
  value       = try(hcloud_server.current[0].network, null)
  description = "The network the Hetzner Cloud server should be attached to."
}

output "firewall_ids" {
  value       = try(hcloud_server.current[0].firewall_ids, null)
  description = "The firewall IDs the server is attached to."
}

output "placement_group_id" {
  value       = try(hcloud_server.current[0].placement_group_id, null)
  description = "The placement group's ID for the new server."
}

output "delete_protection" {
  value       = try(hcloud_server.current[0].delete_protection, null)
  description = "Whether or not deletion protection is enabled for the server."
}

output "rebuild_protection" {
  value       = try(hcloud_server.current[0].rebuild_protection, null)
  description = "Whether or not rebuild protection is enabled for the server."
}

output "primary_disk_size" {
  value       = try(hcloud_server.current[0].primary_disk_size, null)
  description = "Server primary_disk_size value, or null when creation is disabled."
}

output "public_net" {
  value       = try(hcloud_server.current[0].public_net, null)
  description = "Server public_net value, or null when creation is disabled."
}

output "keep_disk" {
  value       = try(hcloud_server.current[0].keep_disk, null)
  description = "Server keep_disk value, or null when creation is disabled."
}

output "rescue" {
  value       = try(hcloud_server.current[0].rescue, null)
  description = "Server rescue value, or null when creation is disabled."
}

output "ssh_keys" {
  value       = try(hcloud_server.current[0].ssh_keys, null)
  description = "Server ssh_keys value, or null when creation is disabled."
}

output "ignore_remote_firewall_ids" {
  value       = try(hcloud_server.current[0].ignore_remote_firewall_ids, null)
  description = "Server ignore_remote_firewall_ids value, or null when creation is disabled."
}

output "shutdown_before_deletion" {
  value       = try(hcloud_server.current[0].shutdown_before_deletion, null)
  description = "Server shutdown_before_deletion value, or null when creation is disabled."
}

output "user_data" {
  value       = try(hcloud_server.current[0].user_data, null)
  description = "User data stored by the server provider, or null."
  sensitive   = true
}
output "cloud_init_rendered" {
  value       = try(data.cloudinit_config.cloud_config[0].rendered, null)
  description = "Rendered cloud-init payload before the server provider hashes it, or null when rendering is disabled."
  sensitive   = true
}
output "cloud_init_id" {
  value       = try(data.cloudinit_config.cloud_config[0].id, null)
  description = "Checksum of the rendered cloud-init configuration, or null."
}
