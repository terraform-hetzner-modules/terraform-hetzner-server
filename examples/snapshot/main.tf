module "server" {
  source             = "../.."
  name               = "snapshot-example"
  type               = "cx23"
  image              = "debian-13"
  cloud_init_enabled = false
}

module "snapshot" {
  source      = "../../modules/snapshot"
  server_id   = module.server.id
  description = "Initial server snapshot"
  labels      = { purpose = "initial" }
  timeouts    = { create = "90m" }
}
