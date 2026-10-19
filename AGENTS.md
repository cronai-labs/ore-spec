# Agent instructions

This repository holds the Ore format specification. `SPEC.md` is the specification, `examples/` are workflow notes that must stay valid under it, and `skills/` holds agent skills for writing workflows and for building tools against the specification. Nothing here is code that runs; the reference implementation is [VaultOre](https://github.com/cronai-labs/vaultore).

## Changing the specification

- **One change, one pull request,** from a branch linked to its issue (`<issue>-<slug>`). Nothing lands on `main` directly. Open the pull request as a draft and fill in the template, including what was verified.
- **Normative text** is anything with MUST, SHOULD or MAY (RFC 2119), a table of keys or attributes, and the grammar. Change it only with an issue that states the problem and, for a new feature, how the reference implementation would behave.
- **Compatibility.** Say in the pull request whether a workflow that was valid before stays valid and behaves the same. Before 1.0 an incompatible change is allowed in a minor version; mark it `!` in the title (`feat(spec)!: …`).
- **Appendix B** records where VaultOre deviates from the specification. When VaultOre changes, update it; it is informative, not normative.
- **Examples** in `examples/` must stay valid under the current version. A change that affects them updates them in the same pull request.
- **Reserved names** (§12) keep their meaning; do not reuse them for something else.
- **Releases** are a separate pull request plus a tag, and the tag is the maintainer's act ([CONTRIBUTING.md](CONTRIBUTING.md#releases)). Do not change the version or date at the top of `SPEC.md` outside a release pull request.

## Writing

- English. One line per paragraph (soft-wrapped); tables, code blocks and front matter keep their own lines.
- Plain, specific sentences. Every rule says who it binds ("a runner MUST …"), and its terms are the ones defined in §1.
- Link sections by number (`§7.1`); keep section numbers stable within a minor version.

## Checks

```sh
make setup   # npm ci
make check   # markdownlint and the offline link check, with section anchors (Docker)
```

Run `make check` before every push; CI runs the same checks plus commitlint on the title and every commit, and `ci-required` must pass.

## Commits and pull request titles

[Conventional Commits](https://www.conventionalcommits.org/), scopes `spec`, `examples`, `readme`, `ci`, `release`, `deps`. Text changes to the specification are `docs(spec): …`, new features `feat(spec): …`. A subject does not start with a capital letter (`docs(spec): ore …`, not `Ore …`); body lines are at most 100 characters. No tool or AI attribution in commits, pull requests or issues.
