# oc-kickstart Installer Testing Guide

Manual testing steps for `oc-kickstart-install` on WSL/Linux environments.

## Prerequisites

- WSL 2 or Linux (x86_64)
- `curl`, `tar`, `mkdir` available
- Network access to GitHub releases
- `~/.config/opencode` should not exist for fresh install testing

## Test Environment Setup

```bash
mkdir -p ~/oc-kickstart-test
cp /path/to/oc-kickstart-install ~/oc-kickstart-test/
chmod +x ~/oc-kickstart-test/oc-kickstart-install
```

---

## Test Cases

### Test 1: Platform Detection

```bash
./oc-kickstart-install --help
```

Expected: help message displays, no platform errors. ✓ Help text clear and complete.

---

### Test 2: Dry Run (Fresh Install)

```bash
rm -rf ~/.config/opencode
./oc-kickstart-install dry-run
```

Expected: `[oc-kickstart] Running in DRY RUN mode`, no files created in `~/.config/opencode`. ✓ No network changes made.

---

### Test 3: Fresh Install

```bash
rm -rf ~/.config/opencode ~/.config/opencode.backups
./oc-kickstart-install install
```

Expected: `[OK] All prerequisites found` · `[OK] Release artifacts downloaded` · `[OK] Installation complete at ~/.config/opencode`

Verify:

```bash
ls -la ~/.config/opencode/
readlink ~/.config/opencode/current
```

✓ `versions/<TAG>/` exists · `current` symlink correct · config files present · `.env` and `local/` NOT created.

---

### Test 4: Status Command

```bash
./oc-kickstart-install status
```

Expected: installation location, current version, available versions. ✓ Output clear and accurate.

---

### Test 5: Update Command

```bash
mkdir -p ~/.config/opencode/local
echo "test_data" > ~/.config/opencode/local/test.txt
echo "NVIDIA_API_KEY=test123" > ~/.config/opencode/.env
./oc-kickstart-install update
cat ~/.config/opencode/.env
cat ~/.config/opencode/local/test.txt
```

Expected: backup created, `.env` and `local/` preserved, new version installed.

---

### Test 6: Rollback Command

```bash
echo "new_data" > ~/.config/opencode/test_rollback.txt
./oc-kickstart-install rollback
ls ~/.config/opencode/test_rollback.txt 2>/dev/null || echo "[OK] File removed by rollback"
```

Expected: previous configuration restored, `.env` and `local/` preserved.

---

### Test 7: Dry Run (Update Mode)

```bash
./oc-kickstart-install status
./oc-kickstart-install dry-run
./oc-kickstart-install status
```

Expected: `[oc-kickstart] Running in DRY RUN mode` · no backup created · installation unchanged.

---

### Test 8: Missing Prerequisites

```bash
PATH="/usr/bin:/bin" ./oc-kickstart-install install 2>&1 | head -20
```

Expected: `[X] Missing required commands: curl` · exit code 1 · no partial installation.

---

### Test 9: Existing Installation (Fresh Install Blocked)

```bash
./oc-kickstart-install status
./oc-kickstart-install install 2>&1 | head -20
```

Expected: `[X] Installation directory already exists at ~/.config/opencode. Use 'update' to refresh or remove the directory manually.` · exit code 1.

---

### Test 10: No Installation (Update Blocked)

```bash
rm -rf ~/.config/opencode ~/.config/opencode.backups
./oc-kickstart-install update 2>&1 | head -20
```

Expected: `[X] No existing installation found at ~/.config/opencode. Use 'install' for fresh installation.` · exit code 1.

---

### Test 11: No Backups (Rollback Blocked)

```bash
rm -rf ~/.config/opencode.backups
./oc-kickstart-install rollback 2>&1 | head -20
```

Expected: `[X] No backups found at ~/.config/opencode.backups` · exit code 1.

---

## Cleanup

```bash
rm -rf ~/.config/opencode ~/.config/opencode.backups ~/oc-kickstart-test
```

---

## Acceptance Criteria

- [x] Installer supports: `install`, `update`, `status`, `rollback`, `dry-run`
- [x] Detects WSL/Linux; rejects unsupported platforms
- [x] Versioned layout: `versions/<TAG>/` + `current` symlink
- [x] Preserves `.env` and `local/` during updates
- [x] Creates backups before updates; supports rollback
- [x] Clear error messages with proper exit codes
- [x] README documents installer commands

## Notes

- The installer uses a placeholder cosign SHA256. In production, pin to the actual release binary SHA256.
- Signature verification is optional if `.sig` is absent (dev/testing).
- For air-gapped environments, pre-download artifacts and modify the installer.
