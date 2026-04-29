---
description: Check for oc-kickstart updates and install latest version
agent: general
model: auto
---

Check for oc-kickstart updates and install if a newer version is available.

!`

# Caveat: This command runs the installer which may prompt for conflict resolution.

# After update completes, you must RESTART OpenCode to pick up new config/skills.

# Get latest version from GitHub

LATEST=$(curl -s https://api.github.com/repos/krajh/oc-kickstart/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
echo "Latest oc-kickstart version: $LATEST"

# Get current installed version from manifest

CURRENT=$(cat ~/.config/opencode/versions/*/.oc-kickstart-manifest.json 2>/dev/null | grep '"version"' | head -1 | cut -d'"' -f4 || echo "unknown")
echo "Current oc-kickstart version: $CURRENT"

# Compare versions

if [ "$LATEST" != "$CURRENT" ] && [ "$CURRENT" != "unknown" ]; then
echo ""
echo "=== Updating oc-kickstart from $CURRENT to $LATEST ==="
  TAG=$LATEST curl -fsSL -o /tmp/oc-kickstart-install "https://github.com/krajh/oc-kickstart/releases/download/${TAG}/oc-kickstart-install"
chmod +x /tmp/oc-kickstart-install
/tmp/oc-kickstart-install update
echo ""
echo "=== Update complete ==="
echo "IMPORTANT: Restart OpenCode to pick up the new config, skills, and agent definitions."
elif [ "$CURRENT" = "unknown" ]; then
echo "Could not determine current version. Run '~/.config/opencode/versions/*/oc-kickstart-install status' to check."
else
echo "oc-kickstart is already up to date ($CURRENT)"
fi

`
