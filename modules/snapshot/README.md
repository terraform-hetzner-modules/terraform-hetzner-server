# Hetzner Server Snapshot Terraform module

Manage a manual snapshot of an existing server.
Invoke this submodule explicitly to capture a point in time.

## Usage

Put this configuration in `main.tf` and supply `server_id` for the resource to capture.

```hcl
variable "server_id" {
  description = "ID of the existing server to snapshot."
  type        = number
}

module "snapshot" {
  source = "terraform-hetzner-modules/server/hetzner//modules/snapshot"

  server_id   = var.server_id
  description = "Before maintenance"
  labels      = { purpose = "maintenance" }
  timeouts    = { create = "90m" }
}
```

## Notes

A snapshot captures a point in time. File changes on the parent do not refresh an existing snapshot.
To capture a new point in time, add another module instance or deliberately replace this resource.
Changing the parent ID replaces the snapshot. Destroying this module deletes its snapshot.
Ensure any required provisioning or application quiescing has completed before creating a snapshot;
Terraform dependencies alone do not guarantee an application-consistent backup.

The `id` output is an image ID usable by a server. `timeouts.create` overrides the provider's 90-minute creation timeout.

See the [schema report](docs/SCHEMA.md) for provider coverage and the
[parent module](../../README.md) for examples and contribution guidelines.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.7 |
| hcloud | ~> 1.70 |

## Providers

| Name | Version |
| ---- | ------- |
| hcloud | ~> 1.70 |

## Resources

| Name | Type |
| ---- | ---- |
| [hcloud_snapshot.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/snapshot) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| description | Description of the snapshot. Null uses the provider default. | `string` | `null` | no |
| labels | Labels attached to the snapshot. | `map(string)` | `{}` | no |
| server\_id | ID of the source server. Changing this replaces the snapshot. | `number` | n/a | yes |
| timeouts | Operation timeouts. Omitted create uses the provider's 90-minute default. | `object({ create = optional(string) })` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| description | Snapshot description. |
| id | Snapshot id. |
| labels | Snapshot labels. |
| server\_id | Snapshot server id. |
<!-- END_TF_DOCS -->
