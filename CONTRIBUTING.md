# Contributing

Issues are welcome for questions, ambiguities, gaps between the specification and an implementation, and proposals. For a proposal, describe the problem first, with a workflow that shows it.

## How the specification changes

- **One change, one pull request,** from a branch linked to its issue. Nothing lands on `main` directly.
- **Normative text** (anything with MUST, SHOULD or MAY, a table of keys or attributes, the grammar) changes only with an issue that states the problem and, for a new feature, how the reference implementation would behave.
- **Compatibility.** Say in the pull request whether a workflow that was valid before stays valid and behaves the same. Before 1.0 an incompatible change is allowed in a minor version; it is marked `!` in the PR title (`feat(spec)!: …`) and explained in the changelog.
- **Examples** in [examples/](examples/) must stay valid under the current version.

## Commits and pull requests

Pull request titles are [Conventional Commits](https://www.conventionalcommits.org/); the title becomes the squash commit and the changelog entry. Scopes: `spec`, `examples`, `readme`, `ci`, `release`, `deps`. Changes to the specification text are `docs(spec): …`, new features `feat(spec): …`. CI checks the title, the commit messages, Markdown lint and links; `ci-required` must pass.

```sh
make setup   # npm ci
make check   # markdownlint and the offline link check (Docker)
```

## Releases

A release is a pull request that updates `CHANGELOG.md` (`make changelog VERSION=vX.Y.Z`) and the version and date at the top of `SPEC.md`, followed by a tag `vX.Y.Z` on the merged commit. The release workflow publishes `SPEC.md` as an immutable, attested GitHub release.

## Licence

By contributing you agree that your contribution is licensed under [CC BY 4.0](LICENSE), like the rest of the specification.
