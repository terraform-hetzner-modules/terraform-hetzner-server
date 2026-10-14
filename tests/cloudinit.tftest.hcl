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

run "multipart_rendering" {
  command = apply
  variables {
    cloud_init = {
      gzip           = false
      base64_encode  = false
      boundary       = "TESTBOUNDARY"
      include_config = false
      parts = [
        { content = "#cloud-config\npackages: [curl]\n", content_type = "text/cloud-config", filename = "packages.yaml", merge_type = "list(append)" },
        { content = "#!/bin/sh\necho ready\n", content_type = "text/x-shellscript", filename = "bootstrap.sh" }
      ]
    }
  }
  assert {
    condition     = strcontains(output.cloud_init_rendered, "TESTBOUNDARY") && strcontains(output.cloud_init_rendered, "X-Merge-Type: list(append)") && strcontains(output.cloud_init_rendered, "text/x-shellscript") && length(regexall("Content-Disposition:", output.cloud_init_rendered)) == 2
    error_message = "Real cloudinit provider must render both MIME parts, boundary, and merge headers."
  }
  assert {
    condition     = data.cloudinit_config.cloud_config[0].part[0].filename == "packages.yaml" && data.cloudinit_config.cloud_config[0].part[1].filename == "bootstrap.sh"
    error_message = "MIME part order must be preserved."
  }
}
run "reject_invalid_encoding" {
  command = plan
  variables { cloud_init = { gzip = true, base64_encode = false } }
  expect_failures = [var.cloud_init]
}

override_data {
  target = data.hcloud_server_type.current_type
  values = {
    architecture = "arm"
  }
}
