# claude-subchat

Ask a **focused side question** about any highlighted text — a Claude answer, a
code snippet, a term — and get a quick answer in a popup, **without derailing
your main conversation**. Inspired by the [SubChat](https://github.com/LDubya/subchat)
Chrome extension, rebuilt with **no browser extension** and **no API key** (it
reuses your existing Claude Code login).

## Why this is useful

The whole point is **removing the friction of a small question** so you actually
ask it instead of skipping it or losing your place.

- **Your main thread stays clean.** You don't derail the conversation you're in,
  open a new chat, or scroll away to ask "wait, what does this line do?" — the
  answer comes back in a popup and your context is exactly where you left it. In
  Claude Code, the `subchat` agent runs in its *own* context, so side-questions
  never pollute the main task's history.
- **Zero setup per question.** Highlight → one keystroke. Compare that to: open a
  new chat, paste the snippet, re-explain the context, ask, then switch back.
  That overhead is why most people just don't ask the small clarifying questions.
- **Works on anything, anywhere.** A Claude answer, a code file, a PDF, a Slack
  message, an error in your terminal — any app with selectable text. It's not
  tied to a website like a browser extension is.
- **No API key, no extra cost, no new account.** It rides your existing Claude
  login, exactly like the original SubChat rode your logged-in session.
- **It lowers the cost of curiosity.** When asking is nearly free, you ask more —
  and understanding the thing in front of you is usually worth 10 seconds.

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

### Code boxes / preview panes (where Services isn't available)

Some views — like Claude's own code blocks and preview panes — use a custom
right-click menu with **no Services submenu**, so ⌥⌘S / right-click won't reach
them. They do offer **Copy**, so use the copy-based trigger instead:

`ask-subchat.sh --copy` sends ⌘C, then answers on the clipboard. Bind it to a
hotkey with a **Shortcut** (one-time, ~30s):

1. Open the **Shortcuts** app → **＋** → name it `Ask in SubChat (copy)`.
2. Add a **Run Shell Script** action, shell `/bin/bash`, script:
   `bash "$HOME/.claude/subchat/ask-subchat.sh" --copy`
3. Open the shortcut's details (ⓘ) → **Add Keyboard Shortcut** → e.g. **⌥⌘V**.
4. First run asks for **Accessibility** permission (for the synthetic ⌘C) — allow it.

Now: select code/preview text → **⌥⌘V** → SubChat answers. One hotkey, no copy
step needed (it copies for you). Works anywhere Copy works, including sandboxed
preview iframes.

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
