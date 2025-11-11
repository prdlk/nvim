# Releases

## latest: Development Build

**Published**: 2025-10-09

## Commits
- de81040: Update to wasmtime version with exceptions support (#880) (Brian G. Merrell) [#880](https://github.com/extism/extism/pull/880)

## v1.12.0: v1.12.0

**Published**: 2025-07-14

## What's Changed
* feat: add Pool type for pooling plugin instances by @zshipko in https://github.com/extism/extism/pull/696
* docs: add more information about wasmtime caching by @nu-wa in https://github.com/extism/extism/pull/863
* Remove key param for PluginPool by @Nutomic in https://github.com/extism/extism/pull/859
* chore(deps): Update prost requirement from 0.13.1 to 0.14.1 by @dependabot[bot] in https://github.com/extism/extism/pull/865
* Update README.md by @Binlogo in https://gi

## v1.11.1: v1.11.1

**Published**: 2025-05-29

## What's Changed
* fix: use gh release download instead of downloading from github action artifacts in dotnet workflow by @mhmd-azeez in https://github.com/extism/extism/pull/857


**Full Changelog**: https://github.com/extism/extism/compare/v1.11.0...v1.11.1

## v1.11.0: v1.11.0

**Published**: 2025-05-27

## What's Changed
* chore: include wasmtime 30 in supported bounds by @zshipko in https://github.com/extism/extism/pull/834
* Remove python from dependabot.yml by @zshipko in https://github.com/extism/extism/pull/835
* fix: throw error on reentrant plugin call by @chrisdickinson in https://github.com/extism/extism/pull/836
* doc: explain how to see plug-in logs by @Pascal-So in https://github.com/extism/extism/pull/839
* fix: better suggestion when encoding is not implemented by @Alessandro

## v1.10.0: v1.10.0

**Published**: 2025-02-10

## What's Changed
* Change `function_exists` to `&self` by @milesj in https://github.com/extism/extism/pull/796
* chore: fix clippy by @zshipko in https://github.com/extism/extism/pull/799
* Trigger NuGet package publishing when a new release is published by @mhmd-azeez in https://github.com/extism/extism/pull/805
* fix: improve sdk error messages around imports by @zshipko in https://github.com/extism/extism/pull/806
* feat: added a function to track fuel consumption by @pwnintended in htt

## v1.9.1: v1.9.1

**Published**: 2024-11-26

## What's Changed
* feat: add overview on generating bindings by @nilslice in https://github.com/extism/extism/pull/789
* chore(deps): Bump dawidd6/action-download-artifact from 2 to 6 in /.github/workflows by @dependabot in https://github.com/extism/extism/pull/792
* cleanup: return better errors for wasi command modules by @zshipko in https://github.com/extism/extism/pull/793
* fix: remove unwrap() from extism_compiled_plugin_new by @chrisdickinson in https://github.com/extism/extism/pull/

## v1.9.0: v1.9.0

**Published**: 2024-11-19

## What's Changed
* chore: update to wasmtime 26 by @zshipko in https://github.com/extism/extism/pull/783
* feat: add CompiledPlugin by @zshipko in https://github.com/extism/extism/pull/784
* docs: add comment to fs example by @zshipko in https://github.com/extism/extism/pull/788


**Full Changelog**: https://github.com/extism/extism/compare/v1.8.0...v1.9.0

## v1.8.0: v1.8.0

**Published**: 2024-10-22

## What's Changed
* Fix: no method named `free` found for mutable reference `&mut current_plugin::CurrentPlugin` in the current scope by @billythedummy in https://github.com/extism/extism/pull/773
* fix(plugin_call): set rc to EXIT_SIGNALED_SIGABRT when wasmtime bails out on plugin call by @G4Vi in https://github.com/extism/extism/pull/776
* feat: add ability to access response headers when using `extism:host/env::http_request` by @zshipko in https://github.com/extism/extism/pull/774
* fix: 

## v1.7.0: v1.7.0

**Published**: 2024-09-24

## What's Changed
* chore: define pdk term in README by @Utopiah in https://github.com/extism/extism/pull/766
* feat: add `PluginBuilder::with_wasmtime_config` by @zshipko in https://github.com/extism/extism/pull/764
* cleanup(kernel): only try to re-use free blocks before memory.grow by @zshipko in https://github.com/extism/extism/pull/765
* Adds more details about with_wasmtime_config() limitations by @SebastianHambura in https://github.com/extism/extism/pull/770
* cleanup: host takes own

## v1.6.0: v1.6.0

**Published**: 2024-09-04

## What's Changed
* Add readonly dirs to allowed_paths by @mhmd-azeez in https://github.com/extism/extism/pull/733
* feat(runtime): support log_trace in rust-sdk by @hilaryRope in https://github.com/extism/extism/pull/747
* cleanup: allow shadowing host functions by @zshipko in https://github.com/extism/extism/pull/751
* feat: add releasing x86_64-unknown-linux-musl dynamic library by @G4Vi in https://github.com/extism/extism/pull/753
* chore(deps): Update cbindgen requirement from 0.26 to 

