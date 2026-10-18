---
ore: true
name: Hello
description: Two TypeScript cells, the second reading the first one's output.
permissions:
  network: deny
  vaultRead: allow
  vaultWrite: deny
---

# Hello

The smallest useful Ore workflow. The first cell computes a value; the second depends on it and reads it with `cell()`.

```ore:ts id=greeting
const message = "Hello from Ore";
message;
```

```ore:ts id=shout depends=[greeting]
cell("greeting").toUpperCase();
```

After a run, each cell has an `ore-output` callout below it: `greeting` holds `"Hello from Ore"`, `shout` holds `"HELLO FROM ORE"`.
