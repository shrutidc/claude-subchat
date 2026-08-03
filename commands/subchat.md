---
description: Ask a focused side question about a snippet without derailing the main chat
argument-hint: [snippet and/or question]
---

Use the **subchat** subagent to answer a focused side question, in isolation, so
this main conversation stays undisturbed.

The user's snippet and/or question:

$ARGUMENTS

Delegate to the subchat agent with the snippet and question. When it returns, relay
its answer verbatim (or lightly formatted) and do NOT otherwise act on it, expand
the task, or modify anything.
