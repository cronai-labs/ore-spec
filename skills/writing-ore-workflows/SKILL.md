---
name: writing-ore-workflows
description: Use when writing, reviewing or fixing an Ore workflow — a Markdown note with `ore: true` in its front matter and `ore:ts`, `ore:shell` or `ore:ai` cells (for example for VaultOre in Obsidian) — or when turning a task described in prose into such a note.
---

# Writing Ore workflows

An Ore workflow is a Markdown note that a runner executes: front matter with `ore: true`, fenced code blocks as cells, prose around them. The runner runs the cells in dependency order and writes each output back under its cell. The normative text is [SPEC.md](https://github.com/cronai-labs/ore-spec/blob/main/SPEC.md); this skill is the short form for writing one.

## The shape

````markdown
---
ore: true
name: Summarise a note
description: One line on what the workflow does.
permissions:
  network: allow
  vaultRead: allow
  vaultWrite: deny
---

# Summarise a note

What the workflow is for, in prose. The prose is the documentation.

```ore:ai id=summary temperature=0
Summarise in five bullet points:

{{note:Meetings/2026-10-14 Planning.md}}
```

```ore:ts id=checklist depends=[summary]
cell("summary")
  .split("\n")
  .filter((line) => line.startsWith("- "))
  .map((line) => line.replace(/^- /, "- [ ] "))
  .join("\n");
```
````

## Rules that catch most mistakes

### Front matter (§3)

- `ore: true` must be the boolean, not the string `"true"`. `name` is required.
- Quote versions: `version: "0.1"`. Unquoted, YAML reads a number, and the run fails.
- Unknown keys are ignored in 0.1, so a typo (`permission:`) silently does nothing. Check the key names against §3 and §4.

### Permissions (§4)

- Defaults: `network: deny`, `vaultRead: allow`, `vaultWrite: deny`. Ask for the least the workflow needs, and write each permission out so a reader sees it without knowing the defaults.
- An `ore:ai` cell needs `network: allow`. Note that this also gives every container cell of the workflow the network.
- `ask` makes the runner ask the user. The answer is bound to the note's content: editing the front matter or a cell asks again.
- Never plan for a cell to read or write the editor's configuration folder (`.obsidian`) or the runner's state; the runner hides them whatever the permissions say.

### Cells (§5, §7)

- Every cell needs an `id`, unique in the note, made of letters, digits, `_` and `-`. A cell that uses another cell's output names it in `depends=[a, b]`.
- `ore:ts`: TypeScript under Bun, in a container, with the vault at `/workspace`. The output is the value of the **last top-level expression statement**, serialised as JSON; a cell that ends in a declaration outputs `undefined`. End with an expression (`result;`). Read other cells with `cell("id")`, notes with `vault.read(path)`, and write notes with `vault.write(path, content)` (needs `vaultWrite`).
- `ore:shell`: `sh -lc` in the same image; the output is stdout.
- `ore:ai`: one prompt to the configured provider; the output is the response text, unparsed. Parse it in a later `ore:ts` cell (`JSON.parse(cell("id"))`) if you asked for JSON. Attributes: `model`, `temperature`, `maxTokens`.
- `ore:py` and `ore:go` are reserved: they fail in 0.1.

### Templates (§6)

- `{{cellId}}` and `{{note:Path/To/Note.md}}` work in `ore:ai` cells only. In `ore:ts` use `cell()` and `vault.read()`; in `ore:shell` there are no templates.
- `{{note:…}}` paths are relative to the vault root, used exactly as written (spaces allowed, no `{` or `}`). It needs `vaultRead`.
- Templates resolve in one pass: an output that contains `{{note:…}}` is inserted as text and never loads that note.

### Order and failure (§8)

- Cells run one at a time: cells without dependencies in document order, then each cell once its dependencies have run. A failed cell does not stop the run, but every cell that depends on it fails.
- Writes from `vault.write` are applied after the cell, all or none, and refused if a note the cell read has changed since.

### Outputs (§9)

- Do not write `> [!ore-output]` callouts yourself. The runner writes and replaces them, and keeps a record under `_vaultore/runs/…`.

## Checking a workflow

There is no validator in 0.1. In Obsidian, open the note and run it with VaultOre. Headless, VaultOre's command-line runner (built from source in [cronai-labs/vaultore](https://github.com/cronai-labs/vaultore)) runs it in a scratch vault; read the callouts and the `.json` records:

```sh
vaultore run <workflow>.md --vault <scratch-vault>            # whole workflow
vaultore run <workflow>.md --vault <scratch-vault> --cell <id> # one cell and its dependencies
```

Before you call a workflow done, check: front matter keys spelled as in §3, the permissions it needs and no more, every `depends` id exists, every `ore:ts` cell ends in an expression, templates only in `ore:ai` cells. Then run it.

More: [examples/](https://github.com/cronai-labs/ore-spec/tree/main/examples) and the full [SPEC.md](https://github.com/cronai-labs/ore-spec/blob/main/SPEC.md).
