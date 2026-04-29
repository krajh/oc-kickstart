---
description: Switch oc-kickstart model provider and refresh per-agent defaults
agent: general
model: auto
---

Switch oc-kickstart model provider without manually editing `opencode.json`.

!`

set -e

if [ -z "${1:-}" ]; then
echo "Usage: /oc-kickstart-provider <nvidia|openrouter|opencode> [--models]"
echo "Example: /oc-kickstart-provider openrouter --models"
exit 1
fi

PROVIDER="$1"
shift || true

case "$PROVIDER" in
  nvidia|openrouter|opencode) ;;
  *)
    echo "Invalid provider '$PROVIDER'. Use: nvidia, openrouter, or opencode"
exit 1
;;
esac

if [ -x "./oc-kickstart-install" ]; then
INSTALLER="./oc-kickstart-install"
elif command -v oc-kickstart-install >/dev/null 2>&1; then
INSTALLER="oc-kickstart-install"
elif [ -x "$HOME/.config/opencode/current/oc-kickstart-install" ]; then
INSTALLER="$HOME/.config/opencode/current/oc-kickstart-install"
else
echo "Could not find oc-kickstart-install. Run /oc-kickstart-update or install oc-kickstart first."
exit 1
fi

echo "Switching provider to: $PROVIDER"
$INSTALLER update --provider "$PROVIDER" "$@"

echo "Done. Restart OpenCode to ensure all config changes are picked up."

`
