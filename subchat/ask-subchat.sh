#!/bin/bash
# SubChat — focused side answer for the currently highlighted text.
# Invoked by the "Ask in SubChat" macOS Quick Action (Services menu).
# Reads the selection from stdin (or arguments), asks the subchat persona
# via the `claude` CLI using your existing login (no API key), and shows
# the answer in a popup dialog with a Copy button.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# --- get the text.
# "--copy": grab the current selection by sending Cmd+C, then read the clipboard.
#   Use this for apps whose context menu has no Services submenu (e.g. Claude's
#   code/preview boxes). Needs Accessibility permission for the synthetic Cmd+C.
# otherwise: read the selection the Services menu passed on stdin (fallback: args).
if [ "$1" = "--copy" ]; then
  /usr/bin/osascript -e 'tell application "System Events" to keystroke "c" using command down' >/dev/null 2>&1
  sleep 0.3
  SNIPPET="$(pbpaste)"
else
  SNIPPET="$(cat)"
  if [ -z "${SNIPPET//[[:space:]]/}" ]; then
    SNIPPET="$*"
  fi
fi

if [ -z "${SNIPPET//[[:space:]]/}" ]; then
  /usr/bin/osascript -e 'display dialog "No text was selected." buttons {"OK"} default button "OK" with title "SubChat"'
  exit 0
fi

# --- let the user know it's working (claude can take a few seconds)
/usr/bin/osascript -e 'display notification "Thinking about your selection…" with title "SubChat"' >/dev/null 2>&1

# --- the SubChat persona (same spirit as the subchat agent, inlined for the CLI)
SYS="You are SubChat, a focused side-chat. The user highlighted a snippet and wants a concise, self-contained answer about JUST that snippet, without derailing anything else. Lead with the answer in the first sentence, then add only essential supporting detail. Be brief and direct: no preamble, no 'Great question'. If the snippet is code, explain or answer about it; do not propose edits. Answer from your own knowledge; do not use any tools. Plain text only, no markdown headings."

PROMPT="Snippet:
$SNIPPET

Explain or clarify this snippet concisely. If it is itself a question, answer it."

ANSWER="$(claude -p "$PROMPT" --append-system-prompt "$SYS" 2>&1)"

if [ -z "${ANSWER//[[:space:]]/}" ]; then
  ANSWER="No answer came back. Open Terminal, run 'claude' once to confirm you're logged in, then try again."
fi

# --- show the answer in a popup (Copy button copies it to the clipboard)
TMP="$(mktemp -t subchat)"
printf '%s' "$ANSWER" > "$TMP"

/usr/bin/osascript \
  -e 'on run argv' \
  -e 'set t to (read (POSIX file (item 1 of argv)) as «class utf8»)' \
  -e 'set r to (display dialog t buttons {"Copy", "Close"} default button "Close" with title "SubChat — side answer" giving up after 180)' \
  -e 'if button returned of r is "Copy" then set the clipboard to t' \
  -e 'end run' \
  "$TMP" >/dev/null 2>&1

rm -f "$TMP"
