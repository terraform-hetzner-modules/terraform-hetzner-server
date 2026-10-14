## [2.2.0](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/compare/v2.1.0...v2.2.0) (2026-10-14)

### Features

* **server:** support separate network attachments ([1f3b0be](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/commit/1f3b0bed20eb06e363c248f912b25da11cfb4840))

## [2.1.0](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/compare/v2.0.0...v2.1.0) (2026-10-14)

### Features

* **module:** add optional server snapshot submodule ([3123372](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/commit/3123372845a3230d7fd0c0f6ae8367e88feb8a03))

## [2.0.0](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/compare/v1.0.0...v2.0.0) (2026-10-14)

### ⚠ BREAKING CHANGES

* **module/server:** raise minimum engine and provider requirements.

Require Terraform >= 1.7, hcloud ~> 1.70, and cloudinit ~> 2.4. Check structured
inputs against their declared object types. The deprecated datacenter output
now returns null; use location instead.

### Features

* **module/server:** refresh server configuration and native tests ([9580dd0](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/commit/9580dd0f7298c7b6ec7c2e177ee84a10a0fe47cc))

### Bug Fixes

* **ci:** align release dependencies and Super-Linter authentication ([5d174af](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/commit/5d174afa4ea55f3e2b101ca2fe296e1f046d5997))

## 1.0.0 (2024-11-19)

### Features

* add `placement-group` submodule ([838120c](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/commit/838120ce4f19a22ac69bd759bdd43decf4e4b7c5))

### Bug Fixes

* correct invalid `source` ([4afcbf1](https://github.com/terraform-hetzner-modules/terraform-hetzner-server/commit/4afcbf1870db6c3daf46d000e8d50ff3d91127ee))
