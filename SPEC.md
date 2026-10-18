# The Ore Format

**Version:** 0.1.0

**Status:** Draft

**Date:** 2026-10-18

**Editor:** Tobias Krug, CronAI UG

**Licence:** [CC BY 4.0](LICENSE)

**First published:** 2026-01-18, as `specs/workflow-note-spec.md` in [cronai-labs/vaultore](https://github.com/cronai-labs/vaultore) (commit `398417b`)

**Reference implementation:** [VaultOre](https://github.com/cronai-labs/vaultore) 0.1.x

## Abstract

Ore is a format for executable notes. An Ore workflow is a Markdown note whose front matter says `ore: true` and whose fenced code blocks of type `ore:<kind>` are cells. A runner executes the cells in dependency order, writes each cell's output back into the note as an `ore-output` callout, and keeps a record of every run beside the note. The note declares what its cells may do: reach the network, read the vault, write to it. The prose around the cells stays ordinary Markdown, so a workflow is also its own documentation.

## Status of this document

This is a draft. It describes the format as the reference implementation, VaultOre 0.1.x, reads and runs it. Until 1.0 a minor version may change the format incompatibly; §11 states what 1.0 requires. Features that are reserved but not yet specified are listed in §12.

## 1. Conventions

The key words MUST, MUST NOT, SHOULD, SHOULD NOT and MAY are to be read as described in RFC 2119 and RFC 8174 when, and only when, they appear in capitals.

- **Note:** a Markdown file in a **vault**, a folder of notes. Paths in this document are relative to the vault root and use `/`.
- **Workflow:** a note that is an Ore workflow (§2).
- **Cell:** a fenced code block of an Ore cell type (§5).
- **Runner:** software that executes workflows. A runner that executes container cells uses a **container engine**.
- **Run:** one execution of a workflow or of one cell with its dependencies.
- **Output callout:** the block a runner writes after a cell (§9.1).

## 2. Workflow notes

A workflow has YAML front matter and a Markdown body:

````markdown
---
ore: true
name: My Workflow
---

# My Workflow

Any Markdown.

```ore:ts id=step1
1 + 1;
```

> [!ore-output] step1
> view: [[_vaultore/runs/my-workflow/RUN_ID/step1.md]]
> ![[_vaultore/runs/my-workflow/RUN_ID/step1.md]]
> json: [[_vaultore/runs/my-workflow/RUN_ID/step1.json]]
> run: RUN_ID
> status: success | duration: 0.12s | at: 2026-10-15T08:00:00.000Z
````

A note is a workflow when its front matter parses as YAML and its `ore` key is the boolean `true`. The string `"true"` does not make a note a workflow. A runner MUST NOT execute a note that is not a workflow.

## 3. Front matter

A runner MUST validate the known keys below. A known key with a value of the wrong type MUST fail the run before any cell runs. In this version a runner ignores unknown keys; it MUST still treat them as part of the note's content for permission decisions (§4.3).

### 3.1 Required keys

| Key | Type | Meaning |
|---|---|---|
| `ore` | boolean `true` | Marks the note as a workflow |
| `name` | string | Human-readable name |

### 3.2 Optional keys

| Key | Type | Meaning |
|---|---|---|
| `version` | string | The workflow's own version. YAML reads `0.1` as a number, so quote it: `version: "0.1"` |
| `author` | string | |
| `tags` | list of strings | |
| `description` | string | |

### 3.3 Runtime

```yaml
runtime:
  engine: docker            # docker | podman | colima | apple
  image: oven/bun:1-alpine  # image for ore:ts and ore:shell cells
  timeout: 60               # seconds per container cell
  memoryLimit: "512m"       # container memory limit
  cpuLimit: 1               # container CPU limit
```

| Key | Type | Default | Meaning |
|---|---|---|---|
| `runtime.engine` | string | the runner's setting, else `docker` | Container engine for container cells. When set, it overrides the runner's setting; when that engine is unavailable, the run fails and says the note asked for it |
| `runtime.image` | string | `oven/bun:1-alpine` | Image for every `ore:ts` and `ore:shell` cell. It MUST provide `sh`, and `bun` for `ore:ts` |
| `runtime.timeout` | number | `60` | Seconds a container cell may run; a cell's `timeout` attribute overrides it |
| `runtime.memoryLimit` | string | `"512m"` | Memory limit of a container cell |
| `runtime.cpuLimit` | number | `1` | CPU limit of a container cell |

### 3.4 Permissions

See §4.

### 3.5 Schedule

```yaml
schedule: "0 9 * * 1-5"   # 09:00 on weekdays, in the runner's local time
```

A cron expression with five fields, or six with a leading seconds field. A runner that runs scheduled workflows SHOULD check once a minute. A runner that runs workflows on a schedule inside a user's editor MUST NOT run one until the user has approved that note's exact schedule; a changed schedule needs a new approval.

## 4. Permissions

The note declares what its cells may do:

```yaml
permissions:
  network: deny
  vaultRead: allow
  vaultWrite: deny
  buildNetwork: deny
```

### 4.1 Permissions and defaults

| Permission | Default | Controls |
|---|---|---|
| `network` | `deny` | Network access for container cells. AI cells need it (§7.3) |
| `vaultRead` | `allow` | Whether container cells see the vault, and whether `{{note:}}` may read a note (§6) |
| `vaultWrite` | `deny` | Whether cells may change the vault |
| `buildNetwork` | `deny` | Reserved for dependency downloads of the reserved `ore:py` and `ore:go` cells (§12); controls nothing in this version |

A permission the note does not set takes its default.

### 4.2 Values

| Value | Meaning |
|---|---|
| `allow` | Granted without asking |
| `deny` | Refused without asking |
| `ask` | The runner asks the user, and the answer decides |

### 4.3 What a runner MUST enforce

- **The declaration is the bound.** A runner MUST NOT give a cell more than the permissions resolve to, and MUST enforce them outside the cell: in the container's configuration, and in the runner itself for anything it does on a cell's behalf. A check inside the cell's own code does not count as enforcement.
- **`network: deny`:** container cells run without a network. A runner whose engine cannot switch the network off MUST refuse to run such a cell rather than run it with a network.
- **`vaultRead: deny`:** the vault is not visible inside container cells, except the run's own directory when the cell may write; `{{note:}}` fails.
- **`vaultWrite: deny`:** cells cannot change the vault. The runner's own outputs (§9) are not cell writes and are written regardless.
- **Hidden folders.** Whatever the permissions, a runner MUST keep cells from reading or changing the folder that holds the editor's configuration and plugins (in Obsidian the vault's configuration folder, `.obsidian` unless the user chose another; a runner SHOULD hide `.obsidian` as well, since the choice is per device) and the runner's own state, such as stored permission decisions.
- **`ask` is bound to content.** An answer to `ask` applies to the workflow as it was when the user answered: its front matter as written, unknown keys included, and each cell's type, attributes and content. When any of these changes, the runner MUST ask again. Prose and output callouts SHOULD NOT be part of this binding: the runner rewrites the callouts on every run, and that must not prompt again.

## 5. Cells

### 5.1 Form

````markdown
```ore:<type> <attributes>
<content>
```
````

| Type | Meaning |
|---|---|
| `ore:ts` | TypeScript or JavaScript, run in a container (§7.1) |
| `ore:shell` | A shell script, run in a container (§7.2) |
| `ore:ai` | One completion from an AI provider (§7.3) |
| `ore:py`, `ore:go` | Reserved (§12). A runner that does not support them MUST fail such a cell at run time, not ignore it |

A fence with any other `ore:` type is not a cell. A runner trims the cell's content before running it.

### 5.2 Attribute syntax

Attributes follow the type on the opening fence line, separated by spaces or tabs: `key=value`, `key="value with spaces"`, `key='value'`, or `key=[a, b]` for a list. Keys consist of letters, digits and `_`. A runner ignores unknown attributes in this version.

````markdown
```ore:ai id=summarize depends=[fetch, config] model=gpt-5-mini temperature=0
````

### 5.3 Attributes

| Attribute | Cells | Meaning |
|---|---|---|
| `id` | all | **Required.** Unique within the note. Letters, digits, `_` and `-` only: other characters cannot be referenced as `{{id}}` |
| `depends` | all | Ids of cells that must succeed before this one (§8) |
| `timeout` | `ts`, `shell` | Seconds; overrides `runtime.timeout` |
| `model` | `ai` | Model identifier |
| `temperature` | `ai` | Number |
| `maxTokens` | `ai` | Integer; `max_tokens` is accepted as a synonym |

A missing or duplicate `id`, or a `depends` entry naming no cell of the note, MUST fail the run before any cell runs.

## 6. Templates

Templates are resolved in `ore:ai` cells only. The content of `ore:ts` and `ore:shell` cells is passed on as written.

| Template | Resolves to |
|---|---|
| `{{cellId}}` | That cell's output: a string as it is, any other value as indented JSON. A cell without an output leaves the template as written |
| `{{note:Path/To/Note.md}}` | The content of that note |

The path in `{{note:…}}` is everything between `note:` and the closing `}}`, used as written (not trimmed), relative to the vault root. It may contain spaces; it cannot contain `{` or `}`.

- **One pass.** A runner MUST resolve templates in a single pass over the cell's own text and MUST NOT scan inserted text again. An output that contains `{{note:…}}` reaches the prompt as those characters; text fetched by one cell cannot pull a note into another cell's prompt.
- **Verbatim insertion.** Inserted text MUST arrive as it is. In particular, characters that a replacement function would interpret (such as `$&` in JavaScript's `String.prototype.replace`) MUST NOT be interpreted.
- **`{{note:}}` is a read.** Under `vaultRead: deny`, for a note in a hidden folder (§4.3), for a path that leaves the vault (also through a symbolic link), or when the note cannot be read, the cell MUST fail before anything is sent to a provider. A runner MUST NOT send the unresolved template instead.

## 7. Cell semantics

Each container cell runs in a fresh container that is removed afterwards. Nothing persists between cells except outputs and files in the vault.

### 7.1 `ore:ts`

The content runs as a TypeScript module under Bun, in `runtime.image`, with the vault mounted as the working directory `/workspace` as the permissions allow (§4.3).

- **Output:** the value of the module's last top-level expression statement, awaited, then serialised as JSON. A module that ends in a declaration or block has no value; its output is the text `undefined`.
- **Failure:** a non-zero exit fails the cell with its standard error.

The runner provides these globals:

| Global | Meaning |
|---|---|
| `cell(id)` | The output value of cell `id`: from this run, or its last recorded output if it did not run. Throws if there is none. Name the cell in `depends` so this cell waits for it |
| `vault.read(path)` | The content of a vault note, or this cell's pending write to it. Needs `vaultRead` |
| `vault.exists(path)` | Whether the note exists, including this cell's pending writes. Needs `vaultRead` |
| `vault.write(path, content)` | Records a write; the runner applies it after the cell (below). Needs `vaultWrite`; without `vaultRead`, only inside the run's directory |
| `vault.mkdirp(path)` | Creates a folder. Same rule as `vault.write` |
| `vault.readRaw(path)` | Reads any path inside the container, such as `/proc/meminfo` |
| `vaultore` | `{ runId, outputRoot, runDir, workflowPath }` of this run. The name comes from the reference implementation and may change before 1.0 |

**Vault writes.** Nothing a cell writes with `vault.write` reaches the vault while the cell runs. After the cell has exited successfully, the runner applies its writes, all or none:

- Each write records what the cell last read from that path (a hash of the content, or that nothing was there). If any such note has changed since, the runner MUST apply none of the cell's writes and MUST fail the cell, naming the notes that changed.
- A write to a path the cell never read is applied as given.
- A cell that fails writes nothing.
- A write into a hidden folder (§4.3), or outside the vault, MUST fail the cell, and none of its writes are applied.

### 7.2 `ore:shell`

The content runs as `sh -lc <content>` in `runtime.image`, with the same working directory, mounts and limits as `ore:ts`.

- **Output:** standard output, as a string.
- **Failure:** a non-zero exit fails the cell with its standard error.

### 7.3 `ore:ai`

1. The cell MUST fail unless `network` resolves to `allow`.
2. **Provider and model:** the cell's `model` attribute, else the runner's configuration. A runner MUST NOT send a cell to a different provider than configured because of the model's name; it SHOULD fail a model the configured provider cannot serve before anything is sent.
3. **Prompt:** the cell's content with templates resolved (§6), sent as one user message.
4. **Parameters:** `temperature` and `maxTokens` from the cell, else from the runner's configuration.
5. **Output:** the response text, as a string. It is not parsed; a later cell parses it if it needs structure.

AI cells do not run in a container: the runner calls the provider. What a provider receives is the resolved prompt and nothing else from the vault.

## 8. Execution order

- Cells run **one at a time**. First every cell without dependencies, in document order; then each cell once all of its dependencies have run.
- **A cell runs only when every cell it depends on succeeded.** Otherwise it fails and names the dependency.
- **A failing cell does not stop the run.** Later cells still run; cells that depend on it fail as above.
- **Running one cell** runs it and, transitively, the cells it depends on. A runner MAY offer to run one cell alone, with its dependencies' last recorded outputs.
- **A run does not start** when the front matter or a cell does not parse, or when a needed container engine is unavailable.
- **One run per workflow at a time.** A runner MUST NOT start a second run of a workflow while one is running.

## 9. Outputs

### 9.1 The output callout

After each cell, the runner writes or replaces that cell's callout directly below the cell. It MUST re-read the note first, so edits made while the run was in flight are kept, and MUST NOT recreate a note that was deleted or renamed during the run.

```markdown
> [!ore-output] <cellId>
> view: [[<outputRoot>/runs/<workflow>/<runId>/<cellId>.md]]
> ![[<outputRoot>/runs/<workflow>/<runId>/<cellId>.md]]
> json: [[<outputRoot>/runs/<workflow>/<runId>/<cellId>.json]]
> run: <runId>
> status: success | duration: 0.12s | at: <ISO 8601>
```

A failed cell adds `> error: <message>`. A runner reading a note SHOULD also accept outputs written as `<!-- ore:output:<id> … -->` comments by early drafts, and replace them with a callout on its next write.

### 9.2 Files

`<outputRoot>` is the runner's output folder, `_vaultore` by default. `<workflow>` is the note's path without `.md`. `<runId>` is unique per run; the reference implementation uses the start time with `:` and `.` replaced by `-`, plus six random characters. In file names, every character of `<cellId>` other than letters, digits, `_` and `-` is replaced by `_`.

| File | Content |
|---|---|
| `<outputRoot>/runs/<workflow>/<runId>/<cellId>.json` | The record: `runId`, `workflowPath`, `cellId`, `value`, and `meta` with `status`, `duration`, `timestamp` and, on failure, `error` |
| `<outputRoot>/runs/<workflow>/<runId>/<cellId>.md` | The same output as a note |
| `<outputRoot>/runs/<workflow>/<runId>/run.json` | The run: status (`running`, then `completed`, `failed` or `aborted`), start and finish time, each cell's status and duration |
| `<outputRoot>/runs/<workflow>/index.json` | Every run of the workflow, newest first |

The `.md` output note SHOULD be an [Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) concept: front matter with `type`, `title`, `description`, `cellId`, `runId`, `cellStatus` (not `status`, which OKF reserves for the document lifecycle) and `generated`, and the value in a fenced block in the body.

## 10. Validation

A run MUST fail before any cell runs when:

- the note has no front matter, the front matter is not valid YAML, or a known key has the wrong type (§3);
- a cell has no `id`, two cells share one, or `depends` names an unknown cell (§5.3).

Not validated in this version: unknown front matter keys and cell attributes (ignored), dependency cycles (§12), whether `{{cellId}}` names an upstream cell.

## 11. Versioning and conformance

**Versions.** This specification is versioned with Semantic Versioning. Before 1.0, a minor version MAY change the format incompatibly; its changelog says how. From 1.0 on, an incompatible change needs a new major version. A workflow does not yet declare which version of the format it was written for (§12).

**Conformance.** A runner conforms to Ore 0.1 when it:

1. treats exactly the notes of §2 as workflows;
2. validates as in §3, §5.3 and §10;
3. enforces the permissions as in §4.3, including the hidden folders and binding `ask` to content;
4. runs `ore:ts`, `ore:shell` and `ore:ai` cells as in §7, or fails the cell types it does not support;
5. orders and fails cells as in §8;
6. writes outputs as in §9.

A runner MAY add cell types, front matter keys and attributes of its own; it SHOULD give them names that cannot collide with future versions of this specification, such as a prefix of its own.

**What 1.0 requires.** Every reserved feature in §12 decided: specified, or removed. No incompatible change for a period of real use. A conformance suite of workflows with expected outputs, or a second, independent runner.

## 12. Reserved

Reserved for future versions. A runner MUST NOT give these names another meaning.

- **Conditions:** `runIf` in front matter and `when=` on a cell, possibly evaluated by an AI provider as `{{ai: …}}`.
- **Templates:** `{{block:Note#^blockId}}`, `{{meta:date}}`, `{{meta:vault}}`, `{{cell.field}}` for a field of a structured output, and note references whose path comes from another cell.
- **Cell attributes:** `env`, `retry`, `continueOnError`.
- **Execution:** dependency cycles as a validation error; parallel cells within resource budgets; a `control:` key with `parallel`, `sequential` and `loop` (`until`, `max`).
- **AI cells:** `defaultModel` in front matter; structured (JSON) outputs.
- **Cell types:** `ore:py` (Python 3) and `ore:go` (compiled Go), with `buildNetwork` for their dependency downloads.
- **Format version:** a front matter key naming the version of this specification a workflow targets.
- **Validation:** warnings for unknown keys and attributes; a JSON Schema for the front matter.

## Appendix A. Grammar

```ebnf
workflow     = frontmatter body ;
frontmatter  = "---" newline yaml newline "---" ;
body         = { text | cell | callout } ;
cell         = "```ore:" type attributes newline content "```" ;
callout      = "> [!ore-output] " cellId newline { "> " text newline } ;
type         = "ts" | "shell" | "ai" | "py" | "go" ;
attributes   = { ( " " | tab ) attribute } ;
attribute    = key "=" value ;
key          = letterOrDigitOrUnderscore , { letterOrDigitOrUnderscore } ;
value        = '"' { anyButDoubleQuote } '"'
             | "'" { anyButSingleQuote } "'"
             | "[" { anyButClosingBracket } "]"
             | nonBlank , { nonBlank } ;
```

## Appendix B. Reference implementation

[VaultOre](https://github.com/cronai-labs/vaultore) implements this version: an Obsidian plugin and a command-line runner, in [Obsidian's community plugins](https://community.obsidian.md/plugins/vaultore) since 2026-10-18. Its own specifications go into detail this document leaves to runners: the container flags, the stored permission decisions, the providers' request formats.

Known deviations of VaultOre 0.1.x from this version:

- A `ore:ts` cell whose last statement is a string literal before any other statement (a directive, such as a cell that is only `"text";`) outputs `undefined` instead of the string (§7.1; [vaultore#158](https://github.com/cronai-labs/vaultore/issues/158)).
