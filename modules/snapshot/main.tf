resource "hcloud_snapshot" "current" {
  server_id   = var.server_id
  description = var.description
  labels      = var.labels

  timeouts {
    create = var.timeouts.create
  }
}
