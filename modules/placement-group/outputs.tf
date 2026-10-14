output "id" {
  value       = hcloud_placement_group.current.id
  description = "The unique ID for the new Hetzner Cloud placement group."
}

output "name" {
  value       = hcloud_placement_group.current.name
  description = "The name for the new Hetzner Cloud placement group."
}

output "type" {
  value       = hcloud_placement_group.current.type
  description = "The type for the new Hetzner Cloud placement group."
}

output "labels" {
  value       = hcloud_placement_group.current.labels
  description = "The labels for the new Hetzner Cloud placement group."
}

output "servers" {
  value       = hcloud_placement_group.current.servers
  description = "IDs of servers in this placement group."
}
