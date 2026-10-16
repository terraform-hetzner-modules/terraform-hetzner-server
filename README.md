# Hetzner Server Terraform module

Manage a Cloud server with cloud-init, public and private networking, firewall associations, and placement groups.

## Usage

Copy this configuration into `main.tf` and add the
[provider configuration](#provider-configuration) below in `versions.tf`.

```hcl
resource "hcloud_ssh_key" "admin" {
  name       = "web-admin"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

module "server" {
  source = "terraform-hetzner-modules/server/hetzner"

  name     = "web-01"
  type     = "cx23"
  image    = "ubuntu-24.04"
  labels   = { role = "web" }
  ssh_keys = [hcloud_ssh_key.admin.id]
}
```

This registers your existing public key and injects it when creating the server. Replace the key
path with your own; private key material stays on your machine.

## Provider configuration

Export your Hetzner API token as `HCLOUD_TOKEN`. Put the following in your calling root's `versions.tf`:

```hcl
terraform {
  required_version = ">= 1.7"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.70"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.4"
    }
  }
}

provider "hcloud" {}
```

With both files in place, run `terraform init`, `terraform plan`, and `terraform apply`.
Credentials and provider configuration belong in the calling root.
Terraform >= 1.7 and OpenTofu >= 1.8 are supported.

## Examples

- [Basic](examples/basic): a server with public networking.
- [Full](examples/full): every input and nested setting, cloud-init, and networking alternatives.
- [Network attachments](examples/network-attachments): separate network attachments.
- [Snapshot](examples/snapshot): a manual server snapshot.

## Configuration

### Images and initialization

Choose an image name or ID through `image`, or discover an image with `image_selector`.
The selector filters for the server architecture and can choose the most recent matching image.
`allow_deprecated_images` is retained for compatibility and has no effect; use
`image_selector.include_deprecated` to control discovery.

`cloud_init.config` is rendered as YAML before the ordered `cloud_init.parts`. Use the part fields to
control MIME filenames, content types, and merge behavior. `user_data` takes precedence over rendered
cloud-init. Set `cloud_init_enabled = false` to skip rendering; with null `user_data`, no user data is
sent. Initialization and SSH key injection happen at creation. Manage subsequent operating-system
changes separately; the module ignores changes to the server's `ssh_keys` association.

### Networking and placement

Use `private_networks` for inline networks attached during server creation, or `network_attachments`
for separate resources attached afterward. Both support multiple networks; choose one approach per
server. Keep inline networks for private-only servers and workloads that need networking on first boot.
The singular `private_network` input remains for compatibility and cannot be combined with either map.
Prefer `subnet_id` for dependency ordering, or establish a dependency when supplying `network_id`.

`networking` controls each public IP family and can use independently managed Primary IP IDs.
Use `placement_group.enabled = true` to create a spread group, or supply an existing
`placement_group_id`. The [placement-group submodule](modules/placement-group) also manages groups
independently. Keep one owner for firewall and network associations.

### Lifecycle and snapshots

`enable_protection` controls server deletion and rebuild protection. `create_server = false` disables
server creation and plans removal if the module already manages a server. Review plans before changing
images, location, storage, or other settings that can replace infrastructure.

The [snapshot submodule](modules/snapshot) captures a manual point-in-time image. Existing snapshots
do not refresh when server files change; coordinate any required quiescing before capture.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.7 |
| cloudinit | ~> 2.4 |
| hcloud | ~> 1.70 |

## Providers

| Name | Version |
| ---- | ------- |
| cloudinit | ~> 2.4 |
| hcloud | ~> 1.70 |

## Resources

| Name | Type |
| ---- | ---- |
| [hcloud_server.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server_network.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| allow\_deprecated\_images | Deprecated compatibility input: the provider no longer uses this flag. Use image\_selector.include\_deprecated for image discovery. | `bool` | `false` | no |
| backups | Whether or not to enable Hetzner's automatic backups. | `bool` | `false` | no |
| cloud\_init | Cloud-init MIME configuration. The YAML config part is first, followed by parts in list order. Set include\_config=false for custom parts only. Raw user\_data takes precedence. | ```object({ gzip = optional(bool, true) base64_encode = optional(bool, true) boundary = optional(string, "MIMEBOUNDARY") include_config = optional(bool, true) config = optional(any, {}) parts = optional(list(object({ content = string content_type = optional(string, "text/plain") filename = optional(string) merge_type = optional(string) })), []) })``` | `{}` | no |
| cloud\_init\_enabled | Render cloud-init. Raw user\_data takes precedence; set false to skip rendering. False with user\_data=null sends no user data. | `bool` | `true` | no |
| create\_server | Whether or not to create a Server. This is true by default of course. | `bool` | `true` | no |
| enable\_protection | Enable Hetzner's 'rebuild' and 'delete' protection. | `bool` | `false` | no |
| firewall\_ids | A list of firewall IDs that should be attached to the server on creation. | `list(string)` | `[]` | no |
| ignore\_remote\_firewall\_ids | Ignore any updates to the firewall\_ids argument. | `bool` | `false` | no |
| image | OS image name or numeric image ID. Leave null when using image\_selector. | `string` | `null` | no |
| image\_selector | Discover an image by labels, filtered to the server architecture. Mutually exclusive with image. | ```object({ with_selector = string most_recent = optional(bool, true) include_deprecated = optional(bool, false) with_status = optional(set(string), ["available"]) })``` | `null` | no |
| iso | The name or ID of an ISO image to mount into the machine on creation. | `string` | `null` | no |
| keep\_disk | Whether or not the disk should be kept when scaling servers. This allows for downgrades later down the line. | `bool` | `false` | no |
| labels | A map of label to attach to the server on creation. | `map(string)` | `{}` | no |
| location | Location to create the server in. Null lets Hetzner choose a location; defaults to fsn1. | `string` | `"fsn1"` | no |
| name | The name given to the new server. Must be unique per Hetzner project and a valid hostname in accordance with RFC 1123. | `string` | n/a | yes |
| network\_attachments | Named separate server-network resources, attached after server creation. Use exactly one of network\_id or subnet\_id per entry. Mutually exclusive with inline private networks; empty when create\_server is false. | ```map(object({ network_id = optional(number) subnet_id = optional(string) ip = optional(string) alias_ips = optional(set(string), []) }))``` | `{}` | no |
| networking | Public networking, including existing primary IP IDs. Null uses the provider's dual-stack defaults. | ```object({ ipv4 = optional(number) ipv4_enabled = optional(bool, true) ipv6 = optional(number) ipv6_enabled = optional(bool, true) })``` | `null` | no |
| placement\_group | Create a placement group. Its name defaults to the server name. No group is created when create\_server is false. | ```object({ enabled = optional(bool, false) name = optional(string) type = optional(string, "spread") labels = optional(map(string), {}) })``` | `{}` | no |
| placement\_group\_id | Existing placement group ID. Mutually exclusive with placement\_group.enabled. | `number` | `null` | no |
| private\_network | Compatibility input for one private network. Prefer private\_networks; do not use both. An empty object preserves the v1 no-network behavior. | ```object({ network_id = optional(number) subnet_id = optional(string) ip = optional(string) alias_ips = optional(list(string), []) })``` | `null` | no |
| private\_networks | Named inline private networks, attached during server creation. Mutually exclusive with network\_attachments. Prefer subnet\_id for explicit subnet selection and dependency ordering. | ```map(object({ network_id = optional(number) subnet_id = optional(string) ip = optional(string) alias_ips = optional(list(string), []) }))``` | `{}` | no |
| rescue | If specified the system will boot into the given rescue system to allow for easy installation of custom operating systems. | `string` | `null` | no |
| shutdown\_before\_deletion | Shutdown the server gracefully before deleting it. | `bool` | `true` | no |
| ssh\_keys | A list of SSH key names or IDs, which should be injected into the server at creation. None are injected by default. | `list(string)` | `[]` | no |
| timeouts | Provider operation timeouts, for example { create = "20m" }. Null uses the provider default. | ```object({ create = optional(string) })``` | `{}` | no |
| type | The type of server to create. See the output of Hetzner's CLI hcloud command 'server-type list' for reference. | `string` | n/a | yes |
| user\_data | Raw user data, passed through unchanged and taking precedence over cloud\_init. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| backups | The new server's automatic backup setting (boolean). |
| cloud\_init\_id | Checksum of the rendered cloud-init configuration, or null. |
| cloud\_init\_rendered | Rendered cloud-init payload before the server provider hashes it, or null when rendering is disabled. |
| datacenter | Deprecated compatibility output. Hetzner removed datacenters; use location. Always null. |
| delete\_protection | Whether or not deletion protection is enabled for the server. |
| firewall\_ids | The firewall IDs the server is attached to. |
| id | The internal Hetzner ID for the server. |
| ignore\_remote\_firewall\_ids | Server ignore\_remote\_firewall\_ids value, or null when creation is disabled. |
| image | The image used to create the Hetzner Cloud server. |
| ipv4\_address | The IPv4 address the server is configured with. |
| ipv6\_address | The IPv6 address the server is configured with. |
| ipv6\_network | The IPv6 network the server is configured in. |
| iso | The ID or name of the mounted ISO image. |
| keep\_disk | Server keep\_disk value, or null when creation is disabled. |
| labels | The labels attached to the new Hetzner Cloud server. |
| location | The location of the Hetzner Cloud server. |
| name | The name of the Hetzner Cloud server. |
| network | Inline private networks on the server. See network\_attachments for separately managed attachments. |
| network\_attachments | Separate network attachments keyed by caller-supplied names, including IDs, addresses, and MAC addresses. Empty when server creation is disabled. |
| placement\_group\_id | The placement group's ID for the new server. |
| primary\_disk\_size | Server primary\_disk\_size value, or null when creation is disabled. |
| public\_net | Server public\_net value, or null when creation is disabled. |
| rebuild\_protection | Whether or not rebuild protection is enabled for the server. |
| rescue | Server rescue value, or null when creation is disabled. |
| server\_type | The type of Hetzner Cloud server that was created. |
| shutdown\_before\_deletion | Server shutdown\_before\_deletion value, or null when creation is disabled. |
| ssh\_keys | Server ssh\_keys value, or null when creation is disabled. |
| status | The current server status. |
| user\_data | User data stored by the server provider, or null. |
<!-- END_TF_DOCS -->

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for local checks and contribution guidelines, and
[UPGRADING.md](docs/UPGRADING.md) for compatibility and live acceptance checks. The generated
[schema report](docs/SCHEMA.md) documents provider coverage and intentional omissions.

## Authors

Maintained by [Terraform Hetzner Modules](https://github.com/terraform-hetzner-modules).
See [AUTHORS](.github/AUTHORS) and [CODEOWNERS](.github/CODEOWNERS).

## License

MIT. See [LICENSE](LICENSE).
