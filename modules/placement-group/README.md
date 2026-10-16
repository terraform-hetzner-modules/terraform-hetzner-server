# Hetzner Placement Group Terraform module

Manage a spread placement group independently of any individual server.

## Usage

Put this configuration in `main.tf`. Pass `module.placement_group.id` as a server's
`placement_group_id` when creating the server.

```hcl
module "placement_group" {
  source = "terraform-hetzner-modules/server/hetzner//modules/placement-group"

  name   = "workers"
  type   = "spread"
  labels = { environment = "production" }
}
```

## Provider configuration

Export your API token as `HCLOUD_TOKEN` and put this in your calling root's `versions.tf`:

```hcl
terraform {
  required_version = ">= 1.7"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.70"
    }
  }
}

provider "hcloud" {}
```

Run `terraform init`, `terraform plan`, and `terraform apply` from the calling root.

## Notes

Spread groups place member servers on different hosts. Assign servers through their own
configuration; creating the group does not move existing servers into it.
When using the parent server module with this group, leave `placement_group.enabled = false`.

See the [full example](../../examples/full) and [parent module](../../README.md).

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
| [hcloud_placement_group.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| labels | Labels to attach to the new Hetzner Cloud placement group. | `map(string)` | `{}` | no |
| name | The name to give to the new Hetzner Cloud placement group. | `string` | n/a | yes |
| type | The type to give to the new Hetzner Cloud placement group. | `string` | `"spread"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| id | The unique ID for the new Hetzner Cloud placement group. |
| labels | The labels for the new Hetzner Cloud placement group. |
| name | The name for the new Hetzner Cloud placement group. |
| servers | IDs of servers in this placement group. |
| type | The type for the new Hetzner Cloud placement group. |
<!-- END_TF_DOCS -->
