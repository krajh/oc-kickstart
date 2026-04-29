```
      /\
     /  \      ___           ___       _      _
    / /\ \    / _ \___ _____/ (_)__ __(_)__ _| |_
   / /  \ \  / , _/ _ `/ __/ / / // / / _ `/  _/
  /_/    \_\/_/ |_|\_,_/\__/_/_/\_, /_/\_,_/\__/
                               /___/
```


# oc-kickstart (OpenCode Kickstart Kit)

A lightweight, installer-first OpenCode configuration kit with **free model providers**. **WSL, Linux, macOS** (x86_64/amd64/arm64).

No paid subscriptions required. Start coding with AI assistance using free-tier models from NVIDIA, OpenRouter, or OpenCode's built-in infrastructure.

## Installation

```bash
# Latest release
TAG=$(curl -s https://api.github.com/repos/krajh/oc-kickstart/releases/latest | grep '"tag_name"' | cut -d'"' -f4)

# Or pin a version: TAG="v0.1.0"

curl -fsSL -o oc-kickstart-install "https://github.com/krajh/oc-kickstart/releases/download/${TAG}/oc-kickstart-install"
chmod +x oc-kickstart-install
./oc-kickstart-install install
```

### Bootstrap installer

```bash
curl -fsSL https://github.com/krajh/oc-kickstart/releases/latest/download/install | bash
```

### Choosing your model provider

The installer prompts on first run. You can also pass it directly or via env:

```bash
./oc-kickstart-install install --provider nvidia    # default
./oc-kickstart-install install --provider openrouter
./oc-kickstart-install install --provider opencode
MODEL_PROVIDER=nvidia ./oc-kickstart-install install  # alternative via env
```

Your choice is saved to `~/.config/opencode/.env`.

#### Provider model tiers

| Agent         | nvidia                                 | openrouter                                    | opencode         | Role                                  |
| ------------- | -------------------------------------- | --------------------------------------------- | ---------------- | ------------------------------------- |
| `strategist`  | `nvidia/llama-3.3-70b-instruct`        | `openrouter/gemini-2.5-flash-exp:free`        | `opencode/default` | Architecture planning                 |
| `implementer` | `nvidia/qwen2.5-coder-32b`             | `openrouter/gemini-2.5-flash-exp:free`        | `opencode/codex` | Code generation                       |
| `reviewer`    | `nvidia/mistral-large`                 | `openrouter/llama-3.2-3b-instruct:free`       | `opencode/default` | Code/doc review                       |
| `research`    | `nvidia/llama-3.3-70b-instruct`        | `openrouter/gemini-2.5-flash-exp:free`        | `opencode/default` | Investigation, large context          |
| `architect`   | `nvidia/llama-3.3-70b-instruct`        | `openrouter/gemini-2.5-flash-exp:free`        | `opencode/default` | Big-picture design                    |

### API keys

| Provider      | API Key               | Required |
|---------------|-----------------------|----------|
| `nvidia`      | `NVIDIA_API_KEY`      | Yes — get a free key at [build.nvidia.com](https://build.nvidia.com) |
| `openrouter`  | `OPENROUTER_API_KEY`  | Yes — sign up at [openrouter.ai](https://openrouter.ai) |
| `opencode`    | None                  | Built-in |

The installer will prompt for missing API keys and persist them to `~/.config/opencode/.env`.

### Verify installation

```bash
oc-kickstart-install status
```

## Updates

```bash
oc-kickstart-install update
```

Or from within OpenCode: `/oc-kickstart-update` — fetches the latest version, compares with installed, and runs the update. **Restart OpenCode** after updating.

To switch provider safely (without manually editing `opencode.json`), use:

```bash
/oc-kickstart-provider openrouter
# or
/oc-kickstart-provider nvidia --models
```

This runs `oc-kickstart-install update --provider ...` and re-applies provider-appropriate per-agent model defaults.

To inspect the supported model IDs from inside OpenCode, use:

```bash
/oc-kickstart-models
/oc-kickstart-models nvidia
/oc-kickstart-models openrouter
/oc-kickstart-models opencode
```

### How conflicts are handled

If you've customised files that oc-kickstart also manages:

1. **Detects changes** via `.oc-kickstart-manifest.json` checksums
2. **3-way merge** — compares your version, old baseline, and new version
3. **Non-interactive** — your file preserved as `<file>.user`, new version applied
4. **Interactive** — prompts `[k]eep / [o]verwrite / [d]iff / [s]kip` per file

```bash
oc-kickstart-install status                          # check pending conflicts
oc-kickstart-install resolve --accept-incoming       # take new version
oc-kickstart-install resolve --keep-mine             # keep yours
```

## Rollback

```bash
oc-kickstart-install rollback
```

Restores the previous version. Your `.env` and `local/` are never touched.

## Uninstall

```bash
rm -rf ~/.config/opencode/versions ~/.config/opencode/current \
       ~/.config/opencode/.oc-kickstart-manifest.json \
       ~/.config/opencode/.oc-kickstart-incoming
```

Your customisations in `local/` and `.env` are always preserved.

## Requirements

- **curl** and **tar**
- **WSL 2**, **Linux**, or **macOS** (x86_64/amd64/arm64)

## How It Works

### File layout

oc-kickstart installs into `~/.config/opencode/`:

```
~/.config/opencode/
├── opencode.json                # Main config (your customisations preserved)
├── AGENTS.md                    # Agent routing and protocol guide
├── agents/                      # Agent prompt templates
├── skills/                      # Playbooks for delegation, testing, architecture
├── protocols/                   # Operating standards and rulesets
├── plugins/                     # Auto-loaded runtime plugins
├── bunfig.toml                  # Bun config (trustedDependencies for opencode-mem)
├── .oc-kickstart-manifest.json  # SHA-256 checksums for update tracking
├── local/                       # Your customisations (never touched by oc-kickstart)
└── .env                         # Environment variables (never touched by oc-kickstart)
```

`.oc-kickstart-incoming/` only appears when an update has staged conflicts.

### Environment variables

| Variable           | Purpose                                      | Default                                        |
| ------------------ | -------------------------------------------- | ---------------------------------------------- |
| `MODEL_PROVIDER`   | Model provider (`nvidia`/`openrouter`/`opencode`) | Prompted on first install; persisted to `.env` |
| `NVIDIA_API_KEY`   | API key (NVIDIA provider only)               | Prompted if provider is `nvidia`               |
| `OPENROUTER_API_KEY` | API key (OpenRouter provider only)         | Prompted if provider is `openrouter`           |
| `BASE_URL`         | Override default API endpoint                | Optional                                       |

## Available Models

### NVIDIA NIM (default provider)

| Model Key               | Full ID                                        |
|-------------------------|------------------------------------------------|
| `llama-3.3-70b-instruct`  | `meta/llama-3.3-70b-instruct`                |
| `llama-3.1-8b-instruct`   | `meta/llama-3.1-8b-instruct`                |
| `nemotron-70b-instruct`   | `nvidia/llama-3.1-nemotron-70b-instruct`     |
| `mixtral-8x7b-instruct`   | `mistralai/mixtral-8x7b-instruct-v0.1`       |
| `mistral-large`           | `mistralai/mistral-large`                     |
| `mistral-nemotron`        | `mistralai/mistral-nemotron`                  |
| `gemma-3-27b-it`          | `google/gemma-3-27b-it`                       |
| `gemma-2-27b-it`          | `google/gemma-2-27b-it`                       |
| `phi-4-mini-instruct`     | `microsoft/phi-4-mini-instruct`               |
| `qwen2.5-coder-32b`       | `qwen/qwen2.5-coder-32b-instruct`             |
| `deepseek-v3.2`           | `deepseek-ai/deepseek-v3.2`                   |

### OpenRouter (free models)

| Model Key                 | Full ID                                        |
|---------------------------|------------------------------------------------|
| `gemini-2.5-flash-exp:free` | `google/gemini-2.5-flash-exp:free`           |
| `llama-3.2-3b-instruct:free` | `meta-llama/llama-3.2-3b-instruct:free`    |
| `mistral-7b-instruct:free`  | `mistralai/mistral-7b-instruct:free`        |
| `phi-3.5-mini-instruct:free` | `microsoft/phi-3.5-mini-instruct:free`     |

### OpenCode (built-in)

| Model Key | ID                |
|-----------|-------------------|
| `default` | `opencode/default` |
| `codex`   | `opencode/codex`   |
| `mini`    | `opencode/mini`    |

## Skills Library

Skills are playbooks loaded on-demand. All oc-kickstart skills are globally available after installation.

### Delegation & Coordination

| Skill                  | Purpose                                        |
| ---------------------- | ---------------------------------------------- |
| `delegation-protocols` | Agent coordination, continuous reporting       |
| `handoff-patterns`     | 5 handoff types to prevent context loss        |
| `agent-routing`        | Fast specialist selection                      |
| `context-checkpoint`   | Capture project state and decisions            |

### Planning & Assessment

| Skill                         | Purpose                                       |
| ----------------------------- | --------------------------------------------- |
| `effort-complexity-framework` | Replace time estimates with Effort+Complexity |
| `brainstorming`              | Explore ideas into designs before coding       |

### Development & Code Quality

| Skill                  | Purpose                                         |
| ---------------------- | ----------------------------------------------- |
| `coding-guidelines`    | Reduce common LLM coding mistakes               |
| `tool-selection`       | Fast tool selection (patch→edit→write priority) |
| `git-hygiene`          | Safe git practices and PR discipline            |
| `output-discipline`     | Skimmable outputs with consistent status tags   |

### Quality & Testing

| Skill                      | Purpose                              |
| -------------------------- | ------------------------------------ |
| `verification-and-tests`   | Definition of Done workflow          |
| `verify-loop`              | Run standardized quality gates        |
| `debugging-error-handling` | Error triage and prevention patterns |

### Workflow & Tooling

| Skill                       | Purpose                                         |
| --------------------------- | ----------------------------------------------- |
| `gitbutler`                 | Virtual branch workflow for parallel agent work |
| `opencode-tool-authoring`   | Standards for `.opencode/tool/*.ts` tools       |
| `opencode-plugin-authoring` | Patterns for `plugin/*.ts` runtime plugins      |
| `ralph-loop`                | Iterate-to-done loop for mechanical tasks       |
| `memory-tool-playbook`      | Episodic memory patterns                        |
| `session-end`              | Comprehensive session closure and continuity     |

## Optional Integrations

### Frieren: Durable Memory

Agents work out of the box with `opencode-mem` (30-day rolling memory). For **permanent cross-session memory**, add [Frieren](docs/FRIEREN_INTEGRATION.md):

- **Wisdom plane** — permanent decisions & patterns
- **Session plane** — episodic event capture
- **Codebase plane** — semantic search + dependency graph

See [`docs/FRIEREN_INTEGRATION.md`](docs/FRIEREN_INTEGRATION.md) for setup.

### Shade: Background Task Executor

Requires Frieren. Autonomous background executor that picks up tasks from a queue.

```bash
oc-kickstart-install install --shade
```

**Prerequisites:** Frieren + Pi runtime (`npm install -g @mariozechner/pi-coding-agent`) + tmux.

```bash
# Enqueue from coordinator:
reaper_enqueue({ task: "Fix all TypeScript errors in src/", priority: 3 })

# Monitor:
shade-status    # Is Shade running?
shade-attach    # View live output
```

See [`docs/REAPER_REALM.md`](docs/REAPER_REALM.md) for architecture and troubleshooting.

## Adding Your Own Agents

1. Read `docs/PERSONA_DEFINITION_GUIDE.md`
2. Copy an existing agent in `agents/` as a template
3. Define role, capabilities, scope, escalation criteria, and communication style
4. Register in `opencode.json` and document in `AGENTS.md`

## Support

- **Issues**: [GitHub Issues](https://github.com/krajh/oc-kickstart/issues)

## License

Apache License 2.0 — see [LICENSE](LICENSE).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
