# Ore

**Ore** is a format for executable notes: Markdown files whose cells run, in order, and write their results back into the note. A workflow is a note with `ore: true` in its front matter and fenced code blocks of type `ore:ts`, `ore:shell` or `ore:ai`. The note declares what its cells may do, so you can read the permissions before anything runs.

This repository holds the specification: **[SPEC.md](SPEC.md)**, version 0.1.1 (draft). An overview for readers new to Ore: [cronai.de/en/ore](https://www.cronai.de/en/ore).

## In one example

````markdown
---
ore: true
name: Hello
permissions:
  network: deny
  vaultWrite: deny
---

# Hello

```ore:ts id=greeting
const message = "Hello from Ore";
message;
```

```ore:ts id=shout depends=[greeting]
cell("greeting").toUpperCase();
```
````

A runner executes `greeting`, then `shout`, and writes each output below its cell as an `ore-output` callout: `"Hello from Ore"`, then `"HELLO FROM ORE"`. More in [examples/](examples/).

## What makes it Ore

- **The note is the program and its documentation.** Cells sit in ordinary Markdown; the prose explains them.
- **Permissions live in the note.** `network`, `vaultRead` and `vaultWrite`, each `allow`, `deny` or `ask`, enforced by the runner outside the cell. An answer to `ask` is bound to the workflow's content and asked again when it changes.
- **Outputs come back into the note,** with a record of every run beside it.
- **Code cells run in containers;** AI cells call a provider with the prompt the note spells out, and nothing else from the vault.

## Status

Version 0.1.1 is a draft. It describes the format as [VaultOre](https://github.com/cronai-labs/vaultore) 0.1.x, the reference implementation, reads and runs it. Before 1.0 the format may change incompatibly; [SPEC.md §11](SPEC.md#11-versioning-and-conformance) says what 1.0 requires. Changes are listed in `CHANGELOG.md` from the first release on.

## Origin

Ore was created by Tobias Krug at CronAI UG. The format was first published on 2026-01-18 as `specs/workflow-note-spec.md` in [cronai-labs/vaultore](https://github.com/cronai-labs/vaultore) (commit `398417b`). Since 2026-10-18 the specification is maintained here, apart from its implementation. See [NOTICE.md](NOTICE.md).

## Implementations

| Runner | Kind | Status |
|---|---|---|
| [VaultOre](https://github.com/cronai-labs/vaultore) | Obsidian plugin, and a command-line runner built from source | Reference implementation of 0.1, in [Obsidian's community plugins](https://community.obsidian.md/plugins/vaultore). Known deviations: [SPEC.md Appendix B](SPEC.md#appendix-b-reference-implementation) |

## For agents and tool builders

- **Writing workflows:** the skill [writing-ore-workflows](skills/writing-ore-workflows/SKILL.md) is the specification's short form for authors, with the rules that catch most mistakes.
- **Building a tool:** the skill [implementing-ore](skills/implementing-ore/SKILL.md) maps the conformance items (§11) and the rules that are easy to get wrong, for a runner, a linter, an editor plugin or a converter.
- Both are [Agent Skills](https://agentskills.io): copy a folder from `skills/` into your agent's skills directory (Claude Code: `~/.claude/skills/`).
- [llms.txt](llms.txt) lists these files for language models. Agents changing the specification itself read [AGENTS.md](AGENTS.md).

## Licence and citation

The specification is licensed under [Creative Commons Attribution 4.0 International](LICENSE) (CC BY 4.0): you may share and adapt it, including for commercial use and for implementations, as long as you give credit. Cite it as given in [CITATION.cff](CITATION.cff), or as:

> Tobias Krug, CronAI UG. *The Ore Format*, version 0.1.1 (draft), 2026. <https://github.com/cronai-labs/ore-spec>

## Contributing

Questions, gaps and proposals are welcome as issues. How changes to the specification are made: [CONTRIBUTING.md](CONTRIBUTING.md).
