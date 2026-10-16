# Full server example

The main server call lists every root input. Additional calls demonstrate mutually exclusive
alternatives: image discovery, an independently managed placement group, raw user data, the legacy
single-network input, and a separate network attachment. This example creates three servers.

Supply:

- `ssh_public_keys`: at least one existing OpenSSH public key for the administrative account.
- `admin_cidrs`: the IPv4 or IPv6 networks permitted to reach SSH on the main server.
- `image_selector`: labels matching an existing available x86 snapshot in this project. The snapshot
  must support cloud-init if you expect the raw user data to configure the administrative account.

`iso` and `rescue` default to null for normal boot. Set an ISO name or ID to mount installation media,
or an appropriate rescue system such as `linux64` to boot into rescue mode. These modes can prevent
normal cloud-init initialization; use them deliberately.

The inline networks supply matching network and subnet IDs. Separate attachments require exactly one:
the example sets `subnet_id` and leaves `network_id` null. To use the latter, set the network ID, clear
the subnet ID, and retain an explicit dependency on subnet creation. Alias addresses also need
operating-system configuration. The separate attachment is created after its server.

The main server renders all cloud-init controls, including MIME settings and part merge behavior.
The second server skips rendering and passes raw YAML through `user_data`. `create_server = false`
is a resource toggle, not a preview mode: it plans removal of an already managed server.
`allow_deprecated_images` is shown for compatibility only and has no effect.

## Running the example

Export `HCLOUD_TOKEN`, supply the inputs described in `variables.tf`, then run:

```shell
terraform init
terraform plan
terraform apply
```

This creates real infrastructure. Review the plan and any deletion protection before cleanup.
See the [module README](../../README.md) for provider configuration and input descriptions.
