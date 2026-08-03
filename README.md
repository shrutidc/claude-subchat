# claude-subchat

Ask a **focused side question** about any highlighted text — a Claude answer, a
code snippet, a term — and get a quick answer in a popup, **without derailing
your main conversation**. Inspired by the [SubChat](https://github.com/LDubya/subchat)
Chrome extension, rebuilt with **no browser extension** and **no API key** (it
reuses your existing Claude Code login).

## What's inside

| Piece | Installs to | What it does |
|-------|-------------|--------------|
| `agents/subchat.md` | `~/.claude/agents/` | A Claude Code subagent for focused side-Q&A in its own isolated context |
| `commands/subchat.md` | `~/.claude/commands/` | `/subchat <snippet + question>` — quick-invoke that agent |
| `subchat/ask-subchat.sh` | `~/.claude/subchat/` | Feeds highlighted text to `claude -p` with the SubChat persona, shows a popup |
| `services/Ask in SubChat.workflow` | `~/Library/Services/` | macOS Quick Action: right-click **Services → Ask in SubChat**, or **⌥⌘S** |

## Install

```bash
git clone https://github.com/shrutidc/claude-subchat.git
cd claude-subchat
./install.sh
```

Requires macOS, the [`claude`](https://claude.com/claude-code) CLI on your `PATH`
and logged in (`claude` once in a terminal), and nothing else.

If **⌥⌘S** doesn't fire right after install, log out/in once, or set it under
**System Settings → Keyboard → Keyboard Shortcuts → Services → Text**.

## Use it

- **Anywhere on your Mac:** highlight text → **⌥⌘S** (or right-click →
  Services → Ask in SubChat) → "Thinking…" → answer popup with a **Copy** button.
- **Inside Claude Code:** type `/subchat <paste snippet + your question>`, or say
  "use the subchat agent to explain this: …".

The trigger is a keyboard shortcut / Services menu instead of a floating chip —
macOS reserves cross-app "act on selection" for Services, which is exactly what
this uses.

## Tweak it

**Change the answer style / persona** — edit the `SYS=` string in
`~/.claude/subchat/ask-subchat.sh` (e.g. "answer in one sentence", "always show a
code example"). For the Claude Code agent, edit the body of
`~/.claude/agents/subchat.md`.

**Use a faster/cheaper model for popups** — add a model flag to the `claude -p`
line in `ask-subchat.sh`, e.g. `--model claude-haiku-4-5-20251001`.

**Rebind the keyboard shortcut** — easiest in **System Settings → Keyboard →
Keyboard Shortcuts → Services → Text**. Or set it directly (`@`=⌘, `~`=⌥, `$`=⇧,
`^`=⌃):

```bash
defaults write pbs NSServicesStatus -dict-add "(null) - Ask in SubChat - runWorkflowAsService" \
  '{ "enabled_context_menu" = 1; "enabled_services_menu" = 1; "key_equivalent" = "^~s"; "presentation_modes" = { "ContextMenu" = 1; "ServicesMenu" = 1; }; }'
/System/Library/CoreServices/pbs -flush
```

## What it can't do

It can't draw a floating "Ask" chip that auto-appears on hover over other apps'
windows — only a browser extension living *inside* the web page (the original
SubChat) can do that. The Services menu + hotkey is the closest system-wide
equivalent that needs no extension.
