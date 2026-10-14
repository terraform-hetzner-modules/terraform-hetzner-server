mock_provider "hcloud" {}
provider "cloudinit" {}

run "setup_tests" {
  command = apply

  providers = {
    cloudinit = cloudinit
  }

  module {
    source = "./tests/setup"
  }
}

run "preserve_default_payload" {
  command = apply

  module {
    source = "./tests/fixtures/compatibility"
  }

  # Pass setup outputs through variables for Terraform/OpenTofu compatibility.
  variables {
    expected_rendered = run.setup_tests.rendered
  }

  assert {
    condition     = output.matches_legacy
    error_message = "Default cloud-init must remain byte-for-byte identical to v1 to avoid server replacement."
  }
}
