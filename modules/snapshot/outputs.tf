output "id" {
  description = "Snapshot id."
  value       = hcloud_snapshot.current.id
}

output "server_id" {
  description = "Snapshot server id."
  value       = hcloud_snapshot.current.server_id
}

output "description" {
  description = "Snapshot description."
  value       = hcloud_snapshot.current.description
}

output "labels" {
  description = "Snapshot labels."
  value       = hcloud_snapshot.current.labels
}
