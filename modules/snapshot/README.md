# Cloud server snapshot

Manage a manual snapshot of an existing Cloud server using `hcloud_snapshot`.
The parent module does not create snapshots automatically; invoke this submodule explicitly.

```hcl
module "snapshot" {
  source = "terraform-hetzner-modules/server/hetzner//modules/snapshot"

  server_id = module.server.id
  description = "Before maintenance"
  labels      = { purpose = "maintenance" }
}
```

A snapshot captures a point in time. File changes on the parent do not refresh an existing snapshot.
To capture a new point in time, add another module instance or deliberately replace this resource.
Changing the parent ID replaces the snapshot. Destroying this module deletes its snapshot.
Ensure any required provisioning or application quiescing has completed before creating a snapshot;
Terraform dependencies alone do not guarantee an application-consistent backup.

The `id` output is an image ID usable by a server. `timeouts.create` overrides the provider's 90-minute creation timeout.

See the [schema report](docs/SCHEMA.md) for the resource inventory.
Run `formr schema . -o docs/SCHEMA.md` here to regenerate it.
The report lists `id` as optional/computed because of the provider SDK; it is intentionally
provider-managed, not a creation input. The create timeout is an input-only control.
The parent repository's native Terraform tests cover this submodule with a mock provider.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.70 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_description"></a> [description](#input\_description) | Description of the snapshot. Null uses the provider default. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels attached to the snapshot. | `map(string)` | `{}` | no |
| <a name="input_server_id"></a> [server\_id](#input\_server\_id) | ID of the source server. Changing this replaces the snapshot. | `number` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Operation timeouts. Omitted create uses the provider's 90-minute default. | `object({ create = optional(string) })` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_description"></a> [description](#output\_description) | Snapshot description. |
| <a name="output_id"></a> [id](#output\_id) | Snapshot id. |
| <a name="output_labels"></a> [labels](#output\_labels) | Snapshot labels. |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | Snapshot server id. |
<!-- END_TF_DOCS -->
