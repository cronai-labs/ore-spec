---
ore: true
name: Summarise a note
description: An AI cell summarises a note; a TypeScript cell turns the summary into a checklist.
permissions:
  network: allow     # the AI cell calls the provider
  vaultRead: allow   # {{note:}} reads the note
  vaultWrite: deny
---

# Summarise a note

The AI cell sends one prompt: its text, with the note pasted in where `{{note:…}}` stands. Nothing else from the vault reaches the provider. Permissions hold for the whole workflow: `network: allow` lets the AI cell reach its provider, and it also opens the network to the TypeScript cell's container.

```ore:ai id=summary temperature=0
Summarise the following meeting notes as three short action items, one per line, without numbering:

{{note:Meetings/2026-10-14 Planning.md}}
```

```ore:ts id=checklist depends=[summary]
const lines = String(cell("summary"))
  .split("\n")
  .map((line) => line.trim())
  .filter((line) => line.length > 0);
lines.map((line) => `- [ ] ${line}`).join("\n");
```
