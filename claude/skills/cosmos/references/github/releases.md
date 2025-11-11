# Releases

## v0.53.4: v0.53.4

**Published**: 2025-07-25

# Cosmos SDK v0.53.4 Release Notes

## 🚀 Highlights

This patch release includes minor dependency and non-breaking functionality additions.

This is fully API and state-compatible with all v0.53.x releases.

## 📝 Changelog

Check out the [changelog](https://github.com/cosmos/cosmos-sdk/blob/v0.53.4/CHANGELOG.md) for an exhaustive list of changes or [compare changes](https://github.com/cosmos/cosmos-sdk/compare/v0.53.3...v0.53.4) from the last release.

## v0.53.3: v0.53.3

**Published**: 2025-07-08

# Cosmos SDK v0.53.3 Release Notes

## 🚀 Highlights

This patch release fixes [GHSA-p22h-3m2v-cmgh](https://github.com/cosmos/cosmos-sdk/security/advisories/GHSA-p22h-3m2v-cmgh).
It resolves a `x/distribution` module issue that can halt chains when the historical rewards pool overflows.
Chains using the `x/distribution` module are affected by this issue.

We recommended upgrading to this patch release as soon as possible.

This patch is state-breaking; chains must perform a coordinated

## v0.50.14: v0.50.14

**Published**: 2025-07-08

# Cosmos SDK v0.50.14 Release Notes

## 🚀 Highlights

This patch release fixes [GHSA-p22h-3m2v-cmgh](https://github.com/cosmos/cosmos-sdk/security/advisories/GHSA-p22h-3m2v-cmgh).
It resolves a `x/distribution` module issue that can halt chains when the historical rewards pool overflows.
Chains using the `x/distribution` module are affected by this issue.

We recommended upgrading to this patch release as soon as possible.

This patch is state-breaking; chains must perform a coordinate

## v0.53.2: v0.53.2

**Published**: 2025-06-03

# Cosmos SDK v0.53.2 Release Notes

💬 [**Release Discussion**](https://github.com/orgs/cosmos/discussions/58)

## 🚀 Highlights

Announcing Cosmos SDK v0.53.2

This release is a patch update that includes feedback from early users of Cosmos SDK v0.53.0.

Upgrading to this version of the Cosmos SDK from any `v0.53.x` is trivial and does not require a chain upgrade.

NOTE: `v0.53.1` has been retracted.

## 📝 Changelog

Check out the [changelog](https://github.com/cosmos/cosmos-sdk/b

## v0.53.1: v0.53.1

**Published**: 2025-05-30

# Cosmos SDK v0.53.1 Release Notes

💬 [**Release Discussion**](https://github.com/orgs/cosmos/discussions/58)

## 🚀 Highlights

Announcing Cosmos SDK v0.53.1

This release is a patch update that includes feedback from early users of Cosmos SDK v0.53.0.

Upgrading to this version of the Cosmos SDK from any `v0.53.x` is trivial and does not require a chain upgrade.

## 📝 Changelog

Check out the [changelog](https://github.com/cosmos/cosmos-sdk/blob/v0.53.1/CHANGELOG.md) for an exhaus

## log/v1.6.0: log/v1.6.0

**Published**: 2025-05-13

## Features

* [#24720](https://github.com/cosmos/cosmos-sdk/pull/24720) add `VerboseModeLogger` extension interface and `VerboseLevel` configuration option for increasing log verbosity during sensitive operations such as upgrades.

## v0.53.0: v0.53.0

**Published**: 2025-04-29

# Cosmos SDK v0.53.0 Release Notes

💬 [**Release Discussion**](https://github.com/orgs/cosmos/discussions/58)

## 🚀 Highlights

Announcing Cosmos SDK v0.53

We are pleased to announce the release of Cosmos SDK v0.53! We’re excited to be delivering a new version of the Cosmos SDK that provides key features and updates while minimizing breaking changes so you can focus on what matters most: building.

Upgrading to this verison of the Cosmos SDK from any `v0.50.x` release will **require a

## v0.53.0-rc.3: v0.53.0-rc.3

**Published**: 2025-04-10

## schema/v1.1.0: schema/v1.1.0

**Published**: 2025-04-09

## Breaking Changes

`cosmossdk.io/schema` was previously tagged as `v1.0.0`, but several stubs were included in this release which were unimplemented. `v1.1.0` removes any unimplemented stubs and retracts `v1.0.0` so that the schema v1 API is actually reflective of the codebase.

## v0.53.0-rc.2: v0.53.0-rc.2

**Published**: 2025-04-01

