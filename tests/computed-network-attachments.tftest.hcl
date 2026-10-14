mock_provider "hcloud" {
  mock_resource "hcloud_server" { defaults = { id = "42" } }
}
run "computed_networks_are_plannable" {
  command = plan
  module { source = "./tests/fixtures/computed-network-attachments" }
  assert {
    condition     = output.attachment_keys == ["app", "storage"]
    error_message = "Computed network IDs must not determine attachment keys."
  }
}
