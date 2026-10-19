---
name: implementing-ore
description: Use when building or reviewing software that reads, validates, runs, converts or displays Ore workflows (Markdown notes with `ore: true` and `ore:*` cells) — a runner, an editor plugin, a linter, an importer — or when checking an implementation against the Ore specification.
---

# Implementing Ore

The normative text is [SPEC.md](https://github.com/cronai-labs/ore-spec/blob/main/SPEC.md); read it whole before writing code. This skill is a map of it for implementers: what a conforming runner must do, the rules that are easy to get wrong, and how to test. Pin the version you implement (the `**Version:**` line, and a [release](https://github.com/cronai-labs/ore-spec/releases)) and say it in your documentation.

## Pick your scope

- **A runner** executes workflows and must meet all six conformance items of §11.
- **A reader** (linter, viewer, converter, editor support) needs §2, §3, §5, §6 and Appendix A, and must not execute anything. It should still report what a runner would refuse (§10).
- **A runner with fewer cell types** conforms if it fails the types it does not support at run time, rather than ignoring them (§5.1, §11 item 4).

## Conformance checklist (§11)

Turn each item into tests before you build it.

1. **Which notes are workflows (§2).** Front matter parses as YAML and `ore` is the boolean `true`; the string `"true"` is not. Never execute anything else.
2. **Validation (§3, §5.3, §10).** Fail the run before any cell when the front matter is missing or invalid, a known key has the wrong type, a cell has no `id`, two cells share one, or `depends` names an unknown cell. Unknown keys and attributes are ignored in 0.1.
3. **Permissions (§4.3).**
   - Enforce outside the cell: in the container's configuration and in the runner. A check in the cell's own code is not enforcement.
   - `network: deny` means no network; if the engine cannot switch it off, refuse to run the cell.
   - `vaultRead: deny` hides the vault from container cells (except the run's own directory when the cell may write) and fails `{{note:}}`.
   - Hide the editor's configuration folder (also `.obsidian` when another was chosen) and your own state from cells, whatever the permissions.
   - Bind an answer to `ask` to the front matter as written (unknown keys included) and to each cell's type, attributes and content; ask again when any of them changes. Prose and output callouts are not part of the binding.
4. **Cell semantics (§7).**
   - `ore:ts`: the output is the value of the module's last top-level expression statement, awaited, as JSON. Watch the edge cases: a module that is only a string literal is a directive in some parsers (Babel puts it in `program.directives`); its value is still the string.
   - `vault.write`: apply after the cell exits successfully, all or none; refuse and fail the cell when a note it read has changed since, or a write targets a hidden folder or leaves the vault.
   - `ore:ai`: fail without `network: allow`; never switch provider because of a model's name; send the resolved prompt and nothing else from the vault.
5. **Order and failure (§8).** One cell at a time; dependencies first, otherwise document order. A failed cell does not stop the run, but its dependants fail and name it. One run per workflow at a time.
6. **Outputs (§9).** Re-read the note before replacing a callout, so edits made during the run survive; never recreate a note that was deleted or renamed during the run. Write the run records under `<outputRoot>/runs/…`.

## Rules that are easy to get wrong

- **Templates (§6):** resolve in one pass over the cell's own text and never rescan inserted text. Insert text verbatim: in JavaScript, `String.prototype.replace` with a string replacement interprets `$&`; use a replacer function. A `{{note:}}` that cannot be read fails the cell before anything is sent, never sends the raw template.
- **`{{note:…}}` paths:** everything between `note:` and `}}`, not trimmed, relative to the vault root; follow symbolic links only if the target stays inside the vault.
- **Your own extensions:** cell types, keys and attributes of your own are allowed (§11); give them a prefix so they cannot collide with future versions, and never reuse a reserved name (§12).

## Testing

- Start from [examples/](https://github.com/cronai-labs/ore-spec/tree/main/examples): each describes in prose what a run produces.
- For every MUST in the specification, write one test that passes and one negative control that would pass if the rule were not enforced (a cell that tries to reach the network under `deny`, a write into `.obsidian`, an output containing `{{note:…}}` fed to a later prompt).
- A conformance suite is not published yet; 1.0 requires one or a second independent runner (§11).

## When the specification is unclear or wrong

Open an issue in [cronai-labs/ore-spec](https://github.com/cronai-labs/ore-spec/issues) with the section, the case and what your implementation does. If you deviate on purpose, say so in your documentation, as [VaultOre](https://github.com/cronai-labs/vaultore) does in the specification's Appendix B.
