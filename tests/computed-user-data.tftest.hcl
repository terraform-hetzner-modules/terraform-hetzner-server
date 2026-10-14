mock_provider "hcloud" {}
run "computed_value_is_plannable" {
  command = plan
  module { source = "./tests/fixtures/computed-user-data" }
}
