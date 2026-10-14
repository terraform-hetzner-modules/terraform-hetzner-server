# Upgrade guide

This refresh targets `hetznercloud/hcloud ~> 1.70` and Terraform >= 1.7.
The test matrix covers Terraform 1.7.5/1.16.6 and OpenTofu 1.8.8/1.13.1.
The server module also requires `hashicorp/cloudinit ~> 2.4`.
These are module compatibility tests; older engines are not necessarily in the provider's own supported test matrix.

## Before upgrading

Back up the root configuration's state and commit its dependency lock file. Upgrade the module source
and run `terraform init -upgrade` (or `tofu init -upgrade`). Review the plan before applying it.
Child module lock files do not constrain the consuming root configuration.

The minimum engine/provider versions and typed object inputs are intentional compatibility changes.
Use the next major module release. Unknown object properties may be discarded by Terraform's object
conversion: check property names against the generated input documentation.

Existing resource names and caller-supplied map keys remain stable. Retain those keys when upgrading.
Changes to resource identity, server image, location, or user data can still trigger replacement according
to the provider; no migration can make those configuration changes intrinsically non-destructive.

## Checks

Run `terraform init -backend=false`, `terraform validate`, and `terraform test`
(or the equivalent `tofu` commands). Initialize and validate the examples and
placement-group and snapshot submodules separately. Tests mock cloud resources and use the
real cloudinit provider to check payload rendering.
No cloud credentials are needed and no real infrastructure is created.

Before a production release, exercise creation, a second no-change plan, updates, and teardown in a
disposable Hetzner project. Mocks do not verify live API behavior, quotas, or capacity.

## Provider coverage maintenance

Formr generates the [schema report](SCHEMA.md). With the module initialized,
run `formr schema . -o docs/SCHEMA.md` to regenerate it and
`formr check . --report docs/SCHEMA.md` to check for drift. Use the same engine
and provider selections recorded in the report's provenance.

The current default policy checks inventory completeness and unresolved
analysis. Strict interface coverage and exception annotations are not yet
implemented, so a passing default check does not approve omitted fields.

Regenerate README inputs/outputs with `terraform-docs -c .github/linters/.terraform-docs.yml .`.
Resource IDs remain provider-managed. Deprecated fields are not reintroduced as new inputs.

## Server changes

Datacenter endpoints were removed by Hetzner. The module now uses the server type's architecture and
per-location support data; it has no hard-coded server-type or datacenter lists. `location = null` delegates
location selection to Hetzner. Temporary capacity is not used as a hard precondition.

`image` accepts a name or numeric image ID. Alternatively set `image = null` and use `image_selector`,
including `with_selector`, `most_recent`, `include_deprecated`, and `with_status`. A changing most-recent
snapshot selection can cause server replacement. Snapshot lookups use the server architecture.

`private_networks` is a map of attachments with `network_id` and/or `subnet_id`, `ip`, and `alias_ips`.
The legacy single `private_network` input remains supported, including its empty-object default behavior;
use one interface at a time. Prefer `subnet_id` for subnet selection and dependency ordering.
Alias IPs default to `[]`. Multiple subnets of the same network are still subject to Hetzner's attachment rules.

Use `placement_group_id` for an existing group or `placement_group.enabled = true` to create one.
Managed groups default to the server's name and type `spread`. `create_server = false` returns null server
outputs and performs no image/type lookups or placement-group creation.

`timeouts.create` controls the server creation timeout. Public IP assignment, ISO, rescue, backups,
firewalls, labels, disk retention, and graceful shutdown retain their existing controls.

### User data

The default cloud-init path retains the v1 YAML serialization, MIME metadata, gzip and base64 settings.
A regression test compares its rendered payload byte-for-byte with the original configuration.
For customization, `cloud_init.parts` is an ordered list of content/content_type/filename/merge_type objects.
The generated YAML config part comes first unless `include_config = false`. `boundary` is configurable.

Raw `user_data` takes precedence and is passed through unchanged, including values unknown until apply.
Set `cloud_init_enabled = false` to skip MIME rendering when supplying raw data. The rendering switch is
explicit so computed raw payloads never determine resource counts. For no user data, leave it null and set
`cloud_init_enabled = false`. Changing user data can replace a server. The `cloud_init_rendered` output
contains the full sensitive payload; `user_data` reflects the provider's stored representation (normally a hash).

### Compatibility decisions

`datacenter` remains as an always-null deprecated output. `allow_deprecated_images` remains an unused
compatibility input because the provider no longer implements it. Use image discovery options instead.
The deprecated backup-window output remains absent.

Delete/rebuild protection remains coupled through `enable_protection`, matching the provider's constraints.
`ignore_changes = [ssh_keys]` retains v1 behavior: injected SSH keys are creation-only. Terraform lifecycle
arguments cannot generally be exposed as dynamic variables. Managing SSH access after creation remains
an operating-system configuration task.

New outputs expose primary disk size, public-network configuration, remaining supported server attributes,
and cloud-init rendering/checksum. The placement-group submodule also exports its server IDs.

### Manual snapshots

The additive `modules/snapshot` submodule manages `hcloud_snapshot` independently of server creation.
It exposes the server ID, description, labels, and create timeout; its output ID can be used as an image.
Existing callers create no snapshots unless they invoke the submodule. Snapshots do not refresh when
server files change. The submodule has a separate `docs/SCHEMA.md`; regenerate and check it from that directory.

### Separate network attachments

`network_attachments` adds keyed `hcloud_server_network` resources without changing existing
inline `private_network`/`private_networks` behavior. Each entry accepts exactly one of
`network_id` or `subnet_id`, plus optional `ip` and `alias_ips`. Prefer a subnet resource's
ID to establish dependency ordering. Attach each server to a given network only once.
The new `network_attachments` output includes all attachment attributes; `network`
continues to describe inline networks. `create_server = false` creates no attachments.

Do not mix inline and separate network management for the same server. Separate resources
attach after the server has been created, so they cannot provide networking during its
initial boot. Use inline networks for private-only servers or cloud-init that needs a
private network immediately. Consumers needing completed attachments should reference
the `network_attachments` output rather than only the server's `id`.

Existing callers need no migration. If switching an existing server, back up state,
remove its inline network configuration and import each existing attachment into
`module.<name>.hcloud_server_network.current["<key>"]` using the provider's
`<server_id>-<network_id>` import ID. Inline blocks cannot be migrated using a `moved`
block. Review the plan before applying: do not apply a detach/reattach plan as an
implicit migration. Changes to server, network, subnet, or IP can replace the attachment;
alias IPs can be updated in place. Test migration in a disposable project first.

See the [provider resource documentation](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server_network).
