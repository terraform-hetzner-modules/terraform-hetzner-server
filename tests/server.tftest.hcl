mock_provider "hcloud" {
  mock_data "hcloud_image" { defaults = { architecture = "arm" } }
  mock_resource "hcloud_server" { defaults = { primary_disk_size = 40 } }
  mock_resource "hcloud_placement_group" { defaults = { id = "42", servers = [1] } }
}
variables {
  name     = "test-server"
  type     = "future-arm-type"
  image    = "ubuntu-24.04"
  location = null
}

run "disabled" {
  command = plan
  variables {
    create_server   = false
    placement_group = { enabled = true }
  }
  assert {
    condition     = output.id == null && output.network == null && length(data.hcloud_server_type.current_type) == 0 && length(data.hcloud_image.os) == 0 && length(module.placement_group) == 0 && output.cloud_init_rendered == null
    error_message = "Disabled creation must produce null outputs and no data lookups or placement group."
  }
}
run "defaults_and_dynamic_architecture" {
  command = apply
  assert {
    condition     = data.hcloud_image.os[0].with_architecture == "arm" && output.primary_disk_size == 40
    error_message = "Architecture must come from the server type, including future types."
  }
  assert {
    condition     = data.cloudinit_config.cloud_config[0].gzip && data.cloudinit_config.cloud_config[0].base64_encode && data.cloudinit_config.cloud_config[0].part[0].filename == "cloud-config.yaml"
    error_message = "Default cloud-init encoding and part metadata must preserve v1 behavior."
  }
}
run "existing_placement_and_multiple_networks" {
  command = apply
  variables {
    placement_group_id = 123
    private_networks = {
      app     = { network_id = 11, subnet_id = "11-10.0.1.0/24", ip = "10.0.1.2", alias_ips = ["10.0.1.3"] }
      storage = { subnet_id = "12-10.1.1.0/24" }
    }
    networking         = { ipv4 = 100, ipv4_enabled = true, ipv6_enabled = false }
    timeouts           = { create = "20m" }
    cloud_init_enabled = false
  }
  assert {
    condition     = output.placement_group_id == 123 && length(output.network) == 2 && length(module.placement_group) == 0 && output.cloud_init_rendered == null && hcloud_server.current[0].timeouts.create == "20m"
    error_message = "Existing placement, multiple networks, timeout, and no user data must be supported."
  }
  assert {
    condition     = alltrue([for n in output.network : n.subnet_id != null]) && one(output.public_net).ipv4 == 100
    error_message = "Subnet and primary IP identifiers must reach the provider."
  }
}
run "managed_placement_defaults" {
  command = apply
  variables { placement_group = { enabled = true } }
  assert {
    condition     = output.placement_group_id == 42 && module.placement_group[0].name == "test-server" && module.placement_group[0].type == "spread" && length(module.placement_group[0].servers) == 1
    error_message = "Counted placement group references and defaults must work."
  }
}
run "legacy_private_network" {
  command = apply
  variables { private_network = { network_id = 11 } }
  assert {
    condition     = length(one(output.network).alias_ips) == 0
    error_message = "Missing alias IPs must produce an empty collection, not an invalid empty IP."
  }
}
run "image_id" {
  command = plan
  variables { image = "987654" }
  assert {
    condition     = data.hcloud_image.os[0].id == 987654 && data.hcloud_image.os[0].name == null
    error_message = "Numeric image IDs must bypass name-based lookup."
  }
}
run "image_selector" {
  command = plan
  variables {
    image          = null
    image_selector = { with_selector = "app=web", include_deprecated = true }
  }
  assert {
    condition     = data.hcloud_image.os[0].with_selector == "app=web" && data.hcloud_image.os[0].most_recent && data.hcloud_image.os[0].include_deprecated
    error_message = "Snapshot selectors and discovery options must pass through."
  }
}
run "raw_user_data" {
  command = apply
  variables {
    user_data          = "#!/bin/sh\necho hello\n"
    cloud_init_enabled = false
  }
  assert {
    condition     = output.user_data == "#!/bin/sh\necho hello\n" && output.cloud_init_rendered == null
    error_message = "Raw user data must pass through without MIME encoding."
  }
}
run "reject_two_image_sources" {
  command = plan
  variables { image_selector = { with_selector = "app=web" } }
  expect_failures = [data.hcloud_image.os]
}
run "reject_two_placement_sources" {
  command = plan
  variables {
    placement_group    = { enabled = true }
    placement_group_id = 123
  }
  expect_failures = [hcloud_server.current]
}
run "reject_unknown_location" {
  command = plan
  variables { location = "unsupported" }
  expect_failures = [hcloud_server.current]
}

override_data {
  target = data.hcloud_server_type.current_type
  values = {
    architecture = "arm"
  }
}
