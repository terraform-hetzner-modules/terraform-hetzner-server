output "snapshot_id" {
  description = "Snapshot image ID for restoring or creating a server."
  value       = module.snapshot.id
}
