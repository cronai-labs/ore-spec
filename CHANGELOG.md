# Changelog

All notable changes to the Ore format specification are documented in this file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-11-10

### Breaking changes

- **spec:** A note whose cells depend on each other in a circle, or a cell that depends on itself, was valid and is now invalid.
- **spec:** `runtime.timeout` and a container cell's `timeout` must be numbers greater than zero. A note with `timeout=2m`, `timeout=0` or a `runtime.timeout` of `0` or below is now invalid.
- **spec:** An `id` may hold only `A`-`Z`, `a`-`z`, digits, `_` and `-`; `run` is reserved; two ids must not differ only in letter case. Notes that break these rules are now invalid.
- **spec:** A time limit may be at most 86400 seconds; an id is one to 64 characters and starts with a letter or digit; the Windows device names (`con`, `prn`, `aux`, `nul`, `com0`-`com9`, `lpt0`-`lpt9`) are reserved as ids.
- **spec:** `runtime.cpuLimit` must be a finite number greater than zero, and `runtime.memoryLimit` must not be empty or an amount of zero. A note with either is now invalid.

### Added

- **spec:** A dependency cycle is a validation error ([#29](https://github.com/cronai-labs/ore-spec/pull/29))
- **spec:** A time limit is a number greater than zero ([#30](https://github.com/cronai-labs/ore-spec/pull/30))
- **spec:** Cell ids are validated, and run is reserved ([#31](https://github.com/cronai-labs/ore-spec/pull/31))
- **spec:** Time limits have an upper bound, ids a fixed shape and reserved names ([#35](https://github.com/cronai-labs/ore-spec/pull/35))
- **spec:** Reserve timeout on an ai cell ([#39](https://github.com/cronai-labs/ore-spec/pull/39))
- **spec:** A memory or CPU limit cannot be switched off ([#40](https://github.com/cronai-labs/ore-spec/pull/40))

### Specification

- **spec:** The validation rules say the same in every section ([#34](https://github.com/cronai-labs/ore-spec/pull/34))
- **spec:** A missing name, the order of cells and reading an earlier run's output ([#38](https://github.com/cronai-labs/ore-spec/pull/38))

## [0.1.1] - 2026-10-19

### Specification

- **spec:** Appendix B names the VaultOre versions with the string-literal deviation ([#6](https://github.com/cronai-labs/ore-spec/pull/6))
- **spec:** Appendix B names VaultOre 0.1.3 as the fix for the string-literal deviation ([#8](https://github.com/cronai-labs/ore-spec/pull/8))

## [0.1.0] - 2026-10-18

### Specification

- **spec:** The Ore format specification 0.1.0 (draft) ([#2](https://github.com/cronai-labs/ore-spec/pull/2))

