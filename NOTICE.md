# Notice

**The Ore Format**
Copyright © 2026 CronAI UG (haftungsbeschränkt). Created by Tobias Krug.

The specification in this repository is licensed under the Creative Commons Attribution 4.0 International licence (CC BY 4.0), see [LICENSE](LICENSE). The licence covers the text of the specification and the examples.

## First publication

CronAI UG first published the format, under the name Ore, on **2026-01-18**, as `specs/workflow-note-spec.md` in the public repository [cronai-labs/vaultore](https://github.com/cronai-labs/vaultore), commit `398417b`. That repository's history records the format's development since then. This repository continues the specification from 2026-10-18.

The defining elements of the format, all part of that publication and of this specification:

- a Markdown note marked as executable by `ore: true` in its front matter;
- cells as fenced code blocks of type `ore:<kind>` (`ore:ts`, `ore:shell`, `ore:ai`), with `id` and `depends` attributes;
- results written back below each cell as `[!ore-output]` callouts, with a run record beside the note;
- permissions declared in the note (`network`, `vaultRead`, `vaultWrite`; `allow`, `deny`, `ask`) and enforced by the runner.

## Attribution

When you share or adapt this specification, give credit as CC BY 4.0 requires, for example: "Based on *The Ore Format* by Tobias Krug, CronAI UG (<https://github.com/cronai-labs/ore-spec>), CC BY 4.0", and say what you changed.
