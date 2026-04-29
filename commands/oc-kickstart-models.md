---
description: List supported oc-kickstart model IDs by provider
agent: general
model: auto
---

List the currently configured oc-kickstart model IDs from `opencode.json`.

!`

set -e

PROVIDER="${1:-all}"

case "$PROVIDER" in
all|nvidia|openrouter|opencode) ;;
\*)
echo "Usage: /oc-kickstart-models [all|nvidia|openrouter|opencode]"
exit 1
;;
esac

if [ -f "./opencode.json" ]; then
CONFIG="./opencode.json"
elif [ -f "$HOME/.config/opencode/opencode.json" ]; then
CONFIG="$HOME/.config/opencode/opencode.json"
else
echo "Could not find opencode.json in the current repo or ~/.config/opencode/."
exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
echo "jq is required for /oc-kickstart-models"
exit 1
fi

print_provider() {
local provider="$1"
  echo ""
  echo "[$provider]"
jq -r --arg provider "$provider" '.provider[$provider].models | keys[]' "$CONFIG"
}

if [ "$PROVIDER" = "all" ]; then
print_provider "nvidia"
print_provider "openrouter"
print_provider "opencode"
else
print_provider "$PROVIDER"
fi

`
