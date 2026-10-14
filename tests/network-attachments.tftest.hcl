mock_provider "hcloud" {
  mock_resource "hcloud_server" { defaults = { id = "42" } }
  mock_resource "hcloud_server_network" { defaults = { mac_address = "86:00:00:00:00:01" } }
}
variables {
  name               = "network-attachments"
  type               = "cx23"
  image              = "123"
  location           = null
  cloud_init_enabled = false
}
run "no_attachments_by_default" {
  command = plan
  assert {
    condition     = length(output.network_attachments) == 0
    error_message = "Existing callers must create no separate attachments."
  }
}
run "multiple_attachments" {
  command = apply
  variables {
    network_attachments = {
      app     = { network_id = 11, ip = "10.0.1.2", alias_ips = ["10.0.1.3", "10.0.1.3"] }
      storage = { subnet_id = "12-10.1.1.0/24" }
    }
  }
  assert {
    condition     = keys(output.network_attachments) == ["app", "storage"] && alltrue([for n in output.network_attachments : n.server_id == 42])
    error_message = "Named attachments must use the module's server."
  }
  assert {
    condition     = output.network_attachments.app.network_id == 11 && output.network_attachments.app.ip == "10.0.1.2" && output.network_attachments.app.alias_ips == toset(["10.0.1.3"]) && output.network_attachments.storage.subnet_id == "12-10.1.1.0/24" && length(output.network_attachments.storage.alias_ips) == 0
    error_message = "Network, subnet, IP, and alias configuration must pass through with set semantics."
  }
  assert {
    condition     = output.network_attachments.app.mac_address == "86:00:00:00:00:01" && length(output.network) == 0
    error_message = "Computed attributes must be exported without adding inline networks."
  }
}
run "update_aliases_and_remove_attachment" {
  command = apply
  variables {
    network_attachments = { app = { network_id = 11, ip = "10.0.1.2", alias_ips = ["10.0.1.4"] } }
  }
  assert {
    condition     = keys(output.network_attachments) == ["app"] && output.network_attachments.app.alias_ips == toset(["10.0.1.4"])
    error_message = "Removing another attachment must preserve the remaining key and allow alias updates."
  }
}
run "disabled_server" {
  command = plan
  variables {
    create_server       = false
    network_attachments = { app = { network_id = 11 } }
  }
  assert {
    condition     = length(output.network_attachments) == 0 && output.id == null
    error_message = "Disabled servers must not create network attachments."
  }
}
run "reject_missing_network" {
  command = plan
  variables { network_attachments = { app = {} } }
  expect_failures = [var.network_attachments]
}
run "reject_two_network_identifiers" {
  command = plan
  variables { network_attachments = { app = { network_id = 11, subnet_id = "11-10.0.1.0/24" } } }
  expect_failures = [var.network_attachments]
}
run "reject_inline_map" {
  command = plan
  variables {
    private_networks    = { app = { network_id = 11 } }
    network_attachments = { storage = { network_id = 12 } }
  }
  expect_failures = [hcloud_server.current]
}
run "reject_legacy_inline" {
  command = plan
  variables {
    private_network     = { network_id = 11 }
    network_attachments = { storage = { network_id = 12 } }
  }
  expect_failures = [hcloud_server.current]
}
