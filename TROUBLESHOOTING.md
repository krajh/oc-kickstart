# Troubleshooting

This guide covers common issues with oc-kickstart installation and usage.

## BunInstallFailedError: opencode-mem

**Cause:** The `protobufjs` package postinstall script is blocked by Bun's security policy.

**Fix:** oc-kickstart ships a `bunfig.toml` that includes `trustedDependencies = ["protobufjs"]`. Make sure `~/.config/opencode/bunfig.toml` exists. If not, re-run installation:

```bash
./oc-kickstart-install install
```

## opencode.json Customizations Lost After Update

This shouldn't happen in v0.8.5+. The installer uses file-copy with deep-merge for `opencode.json` — your keys always win.

If customizations were lost:

1. Restore from `~/.config/opencode/opencode.json.user-backup` if a backup exists
2. Re-run installation: `./oc-kickstart-install install`

## Conflicts After Update: Files in `.oc-kickstart-incoming/`

When you update, if you've modified files that oc-kickstart also ships, the new versions are staged to `.oc-kickstart-incoming/` instead of overwriting your changes.

**Resolve conflicts:**

```bash
# See pending conflicts
./oc-kickstart-install status

# Accept new version (overwrites your file)
./oc-kickstart-install resolve --accept-incoming

# Keep your version (discards incoming)
./oc-kickstart-install resolve --keep-mine
```

## Plugin Fails to Load After Install

**Check:** List installed plugins:

```bash
ls ~/.config/opencode/plugins/
```

**Fix:** Re-run installation:

```bash
./oc-kickstart-install install
```

## Auto-updater Not Checking for Updates

The updater checks at most once every 24 hours.

**Force a check:**

```bash
rm ~/.config/opencode/state/oc-kickstart-update.json
# Restart OpenCode
```

## npm install -g Hangs or Fails

This is expected — npm installation is not the recommended path.

**Use curl | bash instead:**

```bash
curl -fsSL "https://github.com/krajh/oc-kickstart/releases/latest/download/install" | bash
```

## Bash Installer Command Not Found

Ensure the installer is in your PATH, or use the full path:

```bash
~/.config/opencode/current/oc-kickstart-install install
```

## NVIDIA_API_KEY Not Found

Set the environment variable before running OpenCode:

```bash
export NVIDIA_API_KEY="your-key-here"
```

Or add it to `~/.config/opencode/.env`:

```
NVIDIA_API_KEY=your-key-here
```

For OpenRouter, use `OPENROUTER_API_KEY` instead. For OpenCode's built-in provider, no API key is required.

## WSL Path Issues

If running on WSL and seeing path errors, ensure your home directory is correctly set:

```bash
echo $HOME
ls -la ~/
```

The installer expects standard WSL paths. If your Windows user folder is mounted at `/mnt/c/Users/`, consider setting up a Linux home directory.

## macOS-Specific Issues

**Permission Denied when running installer:**

```bash
chmod +x oc-kickstart-install
./oc-kickstart-install install
```

**Home directory not found:**

If `echo $HOME` returns empty on macOS, set it explicitly:

```bash
export HOME=$USER
./oc-kickstart-install install
```

**Apple Silicon (M1/M2/M3) Macs:**

The installer should work natively on Apple Silicon. If you see architecture errors, ensure you're using the correct binary for your chip:

```bash
uname -m  # Should show arm64
```

**Bun not found:**

Install Bun on macOS:

```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc  # or ~/.zshrc
```

## Further Help

- GitHub Issues: https://github.com/krajh/oc-kickstart/issues
- Discussions: https://github.com/krajh/oc-kickstart/discussions
