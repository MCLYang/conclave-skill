#!/bin/bash
# Conclave pre-flight check: ping all four agents once; start the debate only when all are reachable.
# Usage: bash preflight.sh [<arena-path>]
#   If no path is given, only pings without writing a log.
#   If a path is given, results are written to 00_preflight/preflight.log.
set -u

ARENA="${1:-}"
PASS=0; FAIL=0
ok()  { echo "  [OK] $1"; PASS=$((PASS+1)); }
bad() { echo "  [FAIL] $1 — $2"; FAIL=$((FAIL+1)); }

LOG=""
append_log() { LOG="${LOG}$1\n"; }

echo "== 1/4 Claude =="
OUT=$(CONDA_NO_PLUGINS=true no_proxy='*' claude -p 'reply with one word: pong' --max-turns 1 2>&1 | tail -5)
echo "$OUT" | grep -qi pong && ok claude || bad claude "$(echo "$OUT" | head -2)"
append_log "claude: $(echo "$OUT" | grep -qi pong && echo pong || echo fail)"

echo "== 2/4 Codex =="
OUT=$(CONDA_NO_PLUGINS=true no_proxy='*' codex exec --skip-git-repo-check -c model_reasoning_effort="low" 'reply with one word: pong' 2>&1 | tail -5)
echo "$OUT" | grep -qi pong && ok codex || bad codex "$(echo "$OUT" | head -2)"
append_log "codex: $(echo "$OUT" | grep -qi pong && echo pong || echo fail)"

echo "== 3/4 Gemini =="
OUT=$(CONDA_NO_PLUGINS=true no_proxy='*' GEMINI_CLI_TRUST_WORKSPACE=true zsh -i -c 'gemini -p "reply with one word: pong"' 2>&1 | tail -5)
echo "$OUT" | grep -qi pong && ok gemini || bad gemini "$(echo "$OUT" | head -2)"
append_log "gemini: $(echo "$OUT" | grep -qi pong && echo pong || echo fail)"

echo "== 4/4 Qwen =="
OUT=$(CONDA_NO_PLUGINS=true no_proxy='*' qwen -p 'reply with one word: pong' 2>&1 | tail -5)
echo "$OUT" | grep -qi pong && ok qwen || bad qwen "$(echo "$OUT" | head -2)"
append_log "qwen: $(echo "$OUT" | grep -qi pong && echo pong || echo fail)"

echo "== Manus External Advisor ==  (The chair must manually verify via mcp__manus_mcp__create_task; this script cannot cover it.)"
append_log "manus: manual"

echo
echo "Result: $PASS OK / $FAIL FAIL"
[ "$FAIL" -eq 0 ] && echo "Ready to debate" || echo "Fix disconnected agents before debating"

# If an arena path was provided, write the log to disk
if [ -n "$ARENA" ] && [ -d "$ARENA/00_preflight" ]; then
  NOW=$(date '+%Y-%m-%d %H:%M:%S')
  cat > "$ARENA/00_preflight/preflight.log" << EOF
# Preflight Log
- Time: $NOW
- Result: $PASS OK / $FAIL FAIL

$(echo -e "$LOG")

$( [ "$FAIL" -eq 0 ] && echo "Status: Ready to debate" || echo "Status: Fix disconnected agents before debating" )
EOF
  echo "Written to: $ARENA/00_preflight/preflight.log"
fi
