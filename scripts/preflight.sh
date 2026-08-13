#!/bin/bash
# Conclave（辩经）赛前点火试验：五家各 ping 一次，全通才开辩。
# 用法: bash preflight.sh [<辩论场路径>]
#   若不传路径，只做点火不落盘日志。
#   若传路径，点火结果写进 00_preflight/preflight.log。
set -u

ARENA="${1:-}"
PASS=0; FAIL=0
ok()  { echo "  [通] $1"; PASS=$((PASS+1)); }
bad() { echo "  [断] $1 —— $2"; FAIL=$((FAIL+1)); }

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

echo "== Manus 外援 ==  (需主席手动跑 mcp__manus_mcp__create_task 最小任务验证，本脚本覆盖不了)"
append_log "manus: manual"

echo
echo "结果: $PASS 通 / $FAIL 断"
[ "$FAIL" -eq 0 ] && echo "可以开辩" || echo "先修断线方再开辩"

# 若传了辩论场路径，落盘
if [ -n "$ARENA" ] && [ -d "$ARENA/00_preflight" ]; then
  NOW=$(date '+%Y-%m-%d %H:%M:%S')
  cat > "$ARENA/00_preflight/preflight.log" << EOF
# Preflight Log
- 时间: $NOW
- 结果: $PASS 通 / $FAIL 断

$(echo -e "$LOG")

$( [ "$FAIL" -eq 0 ] && echo "状态: 可以开辩" || echo "状态: 先修断线方再开辩" )
EOF
  echo "已写入: $ARENA/00_preflight/preflight.log"
fi
