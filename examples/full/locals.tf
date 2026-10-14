locals {
  cloud_init_config = {
    package_update = true
    ssh_pwauth     = false
    disable_root   = true
    users = [{
      name                = "admin"
      groups              = ["sudo"]
      shell               = "/bin/bash"
      sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
      lock_passwd         = true
      ssh_authorized_keys = var.ssh_public_keys
    }]
  }
}
