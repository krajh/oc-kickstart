# Changelog

All notable changes to oc-kickstart are documented here.

## [0.1.0] — 2026-04-17

### Added

- **Initial release** — Fork of ai-kit with free model providers
- **NVIDIA provider** — Default provider using NVIDIA NIM API (`https://integrate.api.nvidia.com/v1`)
- **OpenRouter provider** — Alternative provider with free-tier models
- **OpenCode provider** — Built-in model infrastructure (no API key required)
- **Agent defaults** — All agents default to NVIDIA models:
  - architect/strategist/research: `nvidia/llama-3.3-70b-instruct`
  - implementer: `nvidia/qwen2.5-coder-32b`
  - reviewer: `nvidia/mistral-large`
- **Installer** — Updated with NVIDIA/OpenRouter/OpenCode provider selection
- **Env-based key management** — `NVIDIA_API_KEY` and `OPENROUTER_API_KEY` from environment
- **Commands** — `/oc-kickstart-models`, `/oc-kickstart-provider`, `/oc-kickstart-update`
