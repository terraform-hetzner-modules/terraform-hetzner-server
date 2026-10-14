<p align="center">
    <!-- terraform-hetzner-server -->
<img src="https://cdn.simpleicons.org/terraform/844FBA" alt="Terraform Logo" align="center" width="128">
<img src="https://avatars.githubusercontent.com/u/30047064?s=200&v=4" alt="Hetzner Logo" align="center" width="128">
    <h1 align="center">Hetzner Cloud</h1>
    <h2 align="center"><code>server</code></h2>
</p>

[![License](https://img.shields.io/github/license/terraform-hetzner-modules/terraform-hetzner-server?label=License)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-_>=_1.7-brightgreen?logo=terraform&logoColor=623CE4)][terraform]
[![Opentofu](https://img.shields.io/badge/OpenTofu-_>=_1.8-brightgreen?logo=opentofu)][opentofu]
[![CI Status](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/actions/workflows/testing.yaml/badge.svg)](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/blob/main/.github/workflows/testing.yaml)
[![GitHub Release](https://img.shields.io/github/v/release/terraform-hetzner-modules/terraform-hetzner-server?label=Release)][github_releases]
[![GitHub Activity](https://img.shields.io/github/commit-activity/m/terraform-hetzner-modules/terraform-hetzner-server?label=Commits)][github_commits]
[![Renovate](https://img.shields.io/badge/Renovate-enabled-brightgreen?logo=renovate&logoColor=1A1F6C)][renovate]
[![Pre-Commit](https://img.shields.io/badge/PreCommit-enabled-brightgreen?logo=precommit&logoColor=FAB040)][pre-commit]

A [Terraform module][module] to create and manage servers within [Hetzner Cloud][hetzner] using [`cloud-init`][cloud-init].

## ✨ TL;DR

```hcl
module "server" {
  source = "terraform-hetzner-modules/server/hetzner"

  name   = "web-01"
  type   = "cx23"
  image  = "ubuntu-24.04"
  labels = { role = "web" }
}
```

## Compatibility and examples

Requires Terraform >= 1.7 (OpenTofu >= 1.8 tested) and hcloud ~> 1.70.
See [basic](examples/basic) and [full](examples/full) examples; configure credentials through `HCLOUD_TOKEN`.
The server module additionally requires cloudinit ~> 2.4.
The optional [snapshot submodule](modules/snapshot) captures manual server snapshots;
see the [snapshot example](examples/snapshot). Snapshots do not refresh when server files change.

Use `private_networks` for inline networks attached during server creation, or
`network_attachments` for separate `hcloud_server_network` resources attached afterward.
Both support multiple networks; choose one approach per server. Keep inline networks
for private-only servers and workloads that need private networking on first boot.
See the [separate attachments example](examples/network-attachments).

Read the [upgrade guide](docs/UPGRADING.md) before moving from v1.
The generated [schema report](docs/SCHEMA.md) lists provider fields, module
mappings, and remaining coverage review items.
Run `terraform init -backend=false`, `terraform validate`, and `terraform test`
for credential-free validation and tests.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | ~> 2.4 |
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.70 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_placement_group"></a> [placement\_group](#module\_placement\_group) | ./modules/placement-group | n/a |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allow_deprecated_images"></a> [allow\_deprecated\_images](#input\_allow\_deprecated\_images) | Deprecated compatibility input: the provider no longer uses this flag. Use image\_selector.include\_deprecated for image discovery. | `bool` | `false` | no |
| <a name="input_backups"></a> [backups](#input\_backups) | Whether or not to enable Hetzner's automatic backups. | `bool` | `false` | no |
| <a name="input_cloud_init"></a> [cloud\_init](#input\_cloud\_init) | Cloud-init MIME configuration. The YAML config part is first, followed by parts in list order. Set include\_config=false for custom parts only. Raw user\_data takes precedence. | ```object({ gzip = optional(bool, true) base64_encode = optional(bool, true) boundary = optional(string, "MIMEBOUNDARY") include_config = optional(bool, true) config = optional(any, {}) parts = optional(list(object({ content = string content_type = optional(string, "text/plain") filename = optional(string) merge_type = optional(string) })), []) })``` | `{}` | no |
| <a name="input_cloud_init_enabled"></a> [cloud\_init\_enabled](#input\_cloud\_init\_enabled) | Render cloud-init. Raw user\_data takes precedence; set false to skip rendering. False with user\_data=null sends no user data. | `bool` | `true` | no |
| <a name="input_create_server"></a> [create\_server](#input\_create\_server) | Whether or not to create a Server. This is true by default of course. | `bool` | `true` | no |
| <a name="input_enable_protection"></a> [enable\_protection](#input\_enable\_protection) | Enable Hetzner's 'rebuild' and 'delete' protection. | `bool` | `false` | no |
| <a name="input_firewall_ids"></a> [firewall\_ids](#input\_firewall\_ids) | A list of firewall IDs that should be attached to the server on creation. | `list(string)` | `[]` | no |
| <a name="input_ignore_remote_firewall_ids"></a> [ignore\_remote\_firewall\_ids](#input\_ignore\_remote\_firewall\_ids) | Ignore any updates to the firewall\_ids argument. | `bool` | `false` | no |
| <a name="input_image"></a> [image](#input\_image) | OS image name or numeric image ID. Leave null when using image\_selector. | `string` | `null` | no |
| <a name="input_image_selector"></a> [image\_selector](#input\_image\_selector) | Discover an image by labels, filtered to the server architecture. Mutually exclusive with image. | ```object({ with_selector = string most_recent = optional(bool, true) include_deprecated = optional(bool, false) with_status = optional(set(string), ["available"]) })``` | `null` | no |
| <a name="input_iso"></a> [iso](#input\_iso) | The name or ID of an ISO image to mount into the machine on creation. | `string` | `null` | no |
| <a name="input_keep_disk"></a> [keep\_disk](#input\_keep\_disk) | Whether or not the disk should be kept when scaling servers. This allows for downgrades later down the line. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of label to attach to the server on creation. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Location to create the server in. Null lets Hetzner choose a location; defaults to fsn1. | `string` | `"fsn1"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name given to the new server. Must be unique per Hetzner project and a valid hostname in accordance with RFC 1123. | `string` | n/a | yes |
| <a name="input_network_attachments"></a> [network\_attachments](#input\_network\_attachments) | Named separate server-network resources, attached after server creation. Use exactly one of network\_id or subnet\_id per entry. Mutually exclusive with inline private networks; empty when create\_server is false. | ```map(object({ network_id = optional(number) subnet_id = optional(string) ip = optional(string) alias_ips = optional(set(string), []) }))``` | `{}` | no |
| <a name="input_networking"></a> [networking](#input\_networking) | Public networking, including existing primary IP IDs. Null uses the provider's dual-stack defaults. | ```object({ ipv4 = optional(number) ipv4_enabled = optional(bool, true) ipv6 = optional(number) ipv6_enabled = optional(bool, true) })``` | `null` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | Create a placement group. Its name defaults to the server name. No group is created when create\_server is false. | ```object({ enabled = optional(bool, false) name = optional(string) type = optional(string, "spread") labels = optional(map(string), {}) })``` | `{}` | no |
| <a name="input_placement_group_id"></a> [placement\_group\_id](#input\_placement\_group\_id) | Existing placement group ID. Mutually exclusive with placement\_group.enabled. | `number` | `null` | no |
| <a name="input_private_network"></a> [private\_network](#input\_private\_network) | Compatibility input for one private network. Prefer private\_networks; do not use both. An empty object preserves the v1 no-network behavior. | ```object({ network_id = optional(number) subnet_id = optional(string) ip = optional(string) alias_ips = optional(list(string), []) })``` | `null` | no |
| <a name="input_private_networks"></a> [private\_networks](#input\_private\_networks) | Named inline private networks, attached during server creation. Mutually exclusive with network\_attachments. Prefer subnet\_id for explicit subnet selection and dependency ordering. | ```map(object({ network_id = optional(number) subnet_id = optional(string) ip = optional(string) alias_ips = optional(list(string), []) }))``` | `{}` | no |
| <a name="input_rescue"></a> [rescue](#input\_rescue) | If specified the system will boot into the given rescue system to allow for easy installation of custom operating systems. | `string` | `null` | no |
| <a name="input_shutdown_before_deletion"></a> [shutdown\_before\_deletion](#input\_shutdown\_before\_deletion) | Shutdown the server gracefully before deleting it. | `bool` | `true` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | A list of SSH key names or IDs, which should be injected into the server at creation. None are injected by default. | `list(string)` | `[]` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Provider operation timeouts, for example { create = "20m" }. Null uses the provider default. | ```object({ create = optional(string) })``` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of server to create. See the output of Hetzner's CLI hcloud command 'server-type list' for reference. | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Raw user data, passed through unchanged and taking precedence over cloud\_init. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backups"></a> [backups](#output\_backups) | The new server's automatic backup setting (boolean). |
| <a name="output_cloud_init_id"></a> [cloud\_init\_id](#output\_cloud\_init\_id) | Checksum of the rendered cloud-init configuration, or null. |
| <a name="output_cloud_init_rendered"></a> [cloud\_init\_rendered](#output\_cloud\_init\_rendered) | Rendered cloud-init payload before the server provider hashes it, or null when rendering is disabled. |
| <a name="output_datacenter"></a> [datacenter](#output\_datacenter) | Deprecated compatibility output. Hetzner removed datacenters; use location. Always null. |
| <a name="output_delete_protection"></a> [delete\_protection](#output\_delete\_protection) | Whether or not deletion protection is enabled for the server. |
| <a name="output_firewall_ids"></a> [firewall\_ids](#output\_firewall\_ids) | The firewall IDs the server is attached to. |
| <a name="output_id"></a> [id](#output\_id) | The internal Hetzner ID for the server. |
| <a name="output_ignore_remote_firewall_ids"></a> [ignore\_remote\_firewall\_ids](#output\_ignore\_remote\_firewall\_ids) | Server ignore\_remote\_firewall\_ids value, or null when creation is disabled. |
| <a name="output_image"></a> [image](#output\_image) | The image used to create the Hetzner Cloud server. |
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | The IPv4 address the server is configured with. |
| <a name="output_ipv6_address"></a> [ipv6\_address](#output\_ipv6\_address) | The IPv6 address the server is configured with. |
| <a name="output_ipv6_network"></a> [ipv6\_network](#output\_ipv6\_network) | The IPv6 network the server is configured in. |
| <a name="output_iso"></a> [iso](#output\_iso) | The ID or name of the mounted ISO image. |
| <a name="output_keep_disk"></a> [keep\_disk](#output\_keep\_disk) | Server keep\_disk value, or null when creation is disabled. |
| <a name="output_labels"></a> [labels](#output\_labels) | The labels attached to the new Hetzner Cloud server. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Hetzner Cloud server. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Hetzner Cloud server. |
| <a name="output_network"></a> [network](#output\_network) | Inline private networks on the server. See network\_attachments for separately managed attachments. |
| <a name="output_network_attachments"></a> [network\_attachments](#output\_network\_attachments) | Separate network attachments keyed by caller-supplied names, including IDs, addresses, and MAC addresses. Empty when server creation is disabled. |
| <a name="output_placement_group_id"></a> [placement\_group\_id](#output\_placement\_group\_id) | The placement group's ID for the new server. |
| <a name="output_primary_disk_size"></a> [primary\_disk\_size](#output\_primary\_disk\_size) | Server primary\_disk\_size value, or null when creation is disabled. |
| <a name="output_public_net"></a> [public\_net](#output\_public\_net) | Server public\_net value, or null when creation is disabled. |
| <a name="output_rebuild_protection"></a> [rebuild\_protection](#output\_rebuild\_protection) | Whether or not rebuild protection is enabled for the server. |
| <a name="output_rescue"></a> [rescue](#output\_rescue) | Server rescue value, or null when creation is disabled. |
| <a name="output_server_type"></a> [server\_type](#output\_server\_type) | The type of Hetzner Cloud server that was created. |
| <a name="output_shutdown_before_deletion"></a> [shutdown\_before\_deletion](#output\_shutdown\_before\_deletion) | Server shutdown\_before\_deletion value, or null when creation is disabled. |
| <a name="output_ssh_keys"></a> [ssh\_keys](#output\_ssh\_keys) | Server ssh\_keys value, or null when creation is disabled. |
| <a name="output_status"></a> [status](#output\_status) | The current server status. |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | User data stored by the server provider, or null. |
<!-- END_TF_DOCS -->

### 🔃 Contributing

Refer to our [documentation for contributors][contributing] for contributing guidelines, commit message
formats and versioning tips.

### 📥 Maintainers

This project is owned and maintained by [Terraform Hetzner Modules][org]. Refer to the [`AUTHORS`][authors] or [`CODEOWNERS`][owners]
for more information. You may also use the linked contact details to reach out directly.

### ©️ Copyright

- _Assets provided by:_ **[HashiCorp][hashicorp]**
- _Sources provided by:_ **[Terraform Hetzner Modules][org]** under the **[MIT License][license]**

<!-- INTERNAL REFERENCES -->

<!-- Project references -->

<!-- File references -->

[license]: LICENSE
[contributing]: docs/CONTRIBUTING.md
[authors]: .github/AUTHORS
[owners]: .github/CODEOWNERS

<!-- General links -->

[org]: https://github.com/terraform-hetzner-modules
[terraform]: https://terraform.io
[opentofu]: https://opentofu.org/
[hashicorp]: https://www.hashicorp.com/
[hetzner]: https://hetzner.com
[github_releases]: https://github.com/terraform-hetzner-modules/terraform-hetzner-server/releases
[github_commits]: https://github.com/terraform-hetzner-modules/terraform-hetzner-server/commits/main/

<!-- Third-party -->

[module]: https://registry.terraform.io/modules/terraform-hetzner-modules/server/hetzner/latest
[cloud-init]: https://cloudinit.readthedocs.io/en/latest/
[renovate]: https://renovatebot.com/
[pre-commit]: https://pre-commit.com/
