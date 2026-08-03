#!/bin/bash
# Installs SubChat into your macOS + Claude Code setup:
#   - subchat agent      -> ~/.claude/agents/subchat.md
#   - /subchat command   -> ~/.claude/commands/subchat.md
#   - ask-subchat.sh     -> ~/.claude/subchat/ask-subchat.sh
#   - "Ask in SubChat"   -> ~/Library/Services/  (right-click Services + Cmd+Opt+S)
# Everything runs through your existing Claude login. No API key.
set -e
here="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$HOME/.claude/agents" "$HOME/.claude/commands" "$HOME/.claude/subchat" "$HOME/Library/Services"
cp "$here/agents/subchat.md"      "$HOME/.claude/agents/subchat.md"
cp "$here/commands/subchat.md"    "$HOME/.claude/commands/subchat.md"
cp "$here/subchat/ask-subchat.sh" "$HOME/.claude/subchat/ask-subchat.sh"
chmod +x "$HOME/.claude/subchat/ask-subchat.sh"
cp -R "$here/services/Ask in SubChat.workflow" "$HOME/Library/Services/"

# Bind Cmd+Opt+S to the service (-dict-add, so existing Services shortcuts are kept).
defaults write pbs NSServicesStatus -dict-add "(null) - Ask in SubChat - runWorkflowAsService" \
  '{ "enabled_context_menu" = 1; "enabled_services_menu" = 1; "key_equivalent" = "@~s"; "presentation_modes" = { "ContextMenu" = 1; "ServicesMenu" = 1; }; }'
/System/Library/CoreServices/pbs -flush

echo "Installed."
echo "If Cmd+Opt+S doesn't fire yet: log out/in once, or set it under"
echo "System Settings > Keyboard > Keyboard Shortcuts > Services > Text."
