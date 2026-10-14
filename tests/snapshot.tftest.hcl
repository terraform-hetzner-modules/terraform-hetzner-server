mock_provider "hcloud" {
  mock_resource "hcloud_snapshot" { defaults = { id = "123" } }
}

run "snapshot_defaults" {
  command = apply
  module { source = "./modules/snapshot" }
  variables { server_id = 42 }
  assert {
    condition     = output.server_id == 42 && length(output.labels) == 0
    error_message = "A snapshot must retain its parent ID and default empty labels."
  }
}

run "snapshot_metadata" {
  command = apply
  module { source = "./modules/snapshot" }
  variables {
    server_id   = 43
    description = "Before migration"
    labels      = { purpose = "migration" }
    timeouts    = { create = "25m" }
  }
  assert {
    condition     = output.server_id == 43 && output.description == "Before migration" && output.labels.purpose == "migration"
    error_message = "Snapshot parent, description, and labels must be configurable."
  }
  assert {
    condition     = hcloud_snapshot.current.timeouts.create == "25m"
    error_message = "Snapshot-specific settings and computed attributes must be preserved."
  }
}
