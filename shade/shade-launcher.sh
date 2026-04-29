#!/usr/bin/env bash
# Shade Pico Launcher
# Starts pi with the reaper extension for background task execution.
#
# Usage:
#   ./shade-launcher.sh              # Process one batch, exit
#   ./shade-launcher.sh --persist    # Keep polling every 30s (for tmux)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSION="${SCRIPT_DIR}/extensions/reaper.ts"
PEERAGE_EXT="${SCRIPT_DIR}/extensions/peerage/peerage.ts"
QUEUE_DB="${FRIEREN_QUEUE_DB:-$HOME/.frieren/queue.db}"

PERSIST=false
if [[ "${1:-}" == "--persist" ]]; then
	PERSIST=true
fi

if [[ ! -f "$EXTENSION" ]]; then
	echo "[X] Reaper extension not found: $EXTENSION" >&2
	exit 1
fi

if [[ ! -f "$PEERAGE_EXT" ]]; then
	echo "[X] Peerage extension not found: $PEERAGE_EXT" >&2
	exit 1
fi

if ! command -v pi &>/dev/null; then
	echo "[X] pi not found. Install: npm install -g @mariozechner/pi-coding-agent" >&2
	exit 1
fi

count_pending() {
	bun -e "
    const {Database} = require('bun:sqlite');
    try {
      const db = new Database('$QUEUE_DB');
      const r = db.query(\"SELECT COUNT(*) as c FROM reaper_realm_queue WHERE status='pending'\").get();
      console.log(r?.c ?? 0);
      db.close();
    } catch { console.log(0); }
  " 2>/dev/null || echo "0"
}

# Reset stale manifesting tasks back to pending (dead session recovery)
recover_stale_tasks() {
	bun -e "
    import {Database} from 'bun:sqlite';
    try {
      const db = new Database('$QUEUE_DB');
      const stale = db.query(\"SELECT task_id FROM reaper_realm_queue WHERE status='manifesting' AND datetime(heartbeat_at) < datetime('now', '-120 seconds')\").all();
      if (stale.length > 0) {
        console.log('[!] Recovering ' + stale.length + ' stale task(s) from dead sessions...');
        db.exec(\"UPDATE reaper_realm_queue SET status='pending', heartbeat_at=NULL WHERE status='manifesting' AND datetime(heartbeat_at) < datetime('now', '-120 seconds')\");
      }
      db.close();
    } catch {}
  " 2>/dev/null || true
}

# Background heartbeat watcher — heartbeats manifesting tasks while Pi works
# Usage: start_heartbeat_watcher [pi_pid]
_HEARTBEAT_PID=""
start_heartbeat_watcher() {
	local pi_pid="$1"
	bun -e "
    import {Database} from 'bun:sqlite';
    const db_path = '$QUEUE_DB';
    const interval = setInterval(() => {
      try {
        const db = new Database(db_path);
        db.exec(\"UPDATE reaper_realm_queue SET heartbeat_at = datetime('now'), updated_at = datetime('now') WHERE status = 'manifesting'\");
        db.close();
      } catch {}
    }, 30000);
    // Stop when parent pi exits
    const check = setInterval(() => {
      try { process.kill($pi_pid, 0); } catch { clearInterval(interval); clearInterval(check); process.exit(0); }
    }, 5000);
  " &
	_HEARTBEAT_PID=$!
}

stop_heartbeat_watcher() {
	if [[ -n "$_HEARTBEAT_PID" ]] && kill -0 "$_HEARTBEAT_PID" 2>/dev/null; then
		kill "$_HEARTBEAT_PID" 2>/dev/null || true
		_HEARTBEAT_PID=""
	fi
}

# All NVIDIA NIM models available for cycling (Ctrl+P in interactive mode)
SHADE_MODELS=(
	"nvidia/llama-3.3-70b-instruct"
	"nvidia/llama-3.1-8b-instruct"
	"nvidia/llama-3.1-nemotron-70b-instruct"
	"nvidia/mistralai/mixtral-8x7b-instruct-v0.1"
	"nvidia/mistralai/mistral-large"
	"nvidia/mistralai/mistral-nemotron"
	"nvidia/google/gemma-3-27b-it"
	"nvidia/google/gemma-2-27b-it"
	"nvidia/microsoft/phi-4-mini-instruct"
	"nvidia/qwen/qwen2.5-coder-32b-instruct"
	"nvidia/deepseek-ai/deepseek-v3.2"
)
MODELS_LIST=$(
	IFS=,
	echo "${SHADE_MODELS[*]}"
)

PI_ARGS=(
	--mode print
	--no-extensions
	-e "$EXTENSION"
	-e "$PEERAGE_EXT"
	--no-skills
	--no-prompt-templates
	--provider nvidia
	--model nvidia/llama-3.3-70b-instruct
	--models "$MODELS_LIST"
)

if [[ "$PERSIST" == "true" ]]; then
	echo "========================================="
	echo " Shade — Reaper Realm Executor"
	echo " Polling every 30s | Ctrl+C to stop"
	echo "========================================="
	echo ""

	while true; do
		recover_stale_tasks
		PENDING=$(count_pending)
		if [[ "$PENDING" -gt 0 ]]; then
			echo "[$(date '+%H:%M:%S')] $PENDING pending task(s). Processing..."
			echo "Call reaper_dequeue now. Do not write text. Only call tools." |
				pi "${PI_ARGS[@]}" 2>/dev/null &
			PI_PID=$!
			start_heartbeat_watcher "$PI_PID"
			wait "$PI_PID" 2>/dev/null || true
			stop_heartbeat_watcher
			echo "[$(date '+%H:%M:%S')] Batch complete."
			echo ""
		fi
		sleep 30
	done
else
	recover_stale_tasks
	PENDING=$(count_pending)
	if [[ "$PENDING" == "0" ]]; then
		echo "[OK] No pending tasks. Nothing to do."
		exit 0
	fi
	echo "[OK] Found $PENDING pending task(s). Starting Shade..."
	echo "Call reaper_dequeue now. Do not write text. Only call tools." |
		pi "${PI_ARGS[@]}" &
	PI_PID=$!
	start_heartbeat_watcher "$PI_PID"
	wait "$PI_PID" 2>/dev/null || true
	stop_heartbeat_watcher
fi
