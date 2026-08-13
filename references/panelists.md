# Panelist Roster

Five starting agents + one external advisor. All CLI calls require `no_proxy='*'` prepended (the local system proxy points to a closed localhost port; bypassing the proxy is more stable).

## 1. Hermes (Chair & Panelist)

- This agent itself. Positioning and rebuttals are drafted in-session by the chair, written to disk in the same format as the other four.
- Red line: must not favor itself; views struck down are still recorded under "rejected positions".

## 2. Claude Code

- Command: `no_proxy='*' claude -p '<prompt>' --max-turns 1`
- Auth: official OAuth (zhang@testsprite.com), credentials stored in macOS login keychain.
  Background sessions may fail to read the keychain (security exit 36).
  **DO NOT put passwords in prompts or scripts.** The user must manually unlock the keychain in an interactive terminal before starting a background debate session:
  ```
  security unlock-keychain ~/Library/Keychains/login.keychain-db
  ```
  If still 401: check for and move aside old `~/.claude/.credentials.json`, then retry.
- Update: `claude update`
- Ping: `no_proxy='*' claude -p 'reply with one word: pong' --max-turns 1`

## 3. Codex

- Command: `no_proxy='*' codex exec --skip-git-repo-check -c model_reasoning_effort="medium" '<prompt>'`
  For important sessions, replace medium with xhigh.
- Auth: cmdme.cn relay, sk- key in `~/.codex/auth.json`; in config.toml set
  `requires_openai_auth = false`, `wire_api = "responses"`, `base_url = "https://cmdme.cn"`.
- Pitfall: exec defaults to a read-only sandbox; file writes are rejected → prompts must require "full text to stdout",
  and the chair extracts the output via `process(action='log', offset=0, limit=400)` to disk.
- Update: `codex update`
- Ping: `no_proxy='*' codex exec --skip-git-repo-check 'reply with one word: pong'`

## 4. Gemini CLI

- Command: `no_proxy='*' GEMINI_CLI_TRUST_WORKSPACE=true zsh -i -c 'gemini -p "<prompt>"'`
- Pitfall: since 0.55.1 a trust-directory check was added; non-interactive calls must carry `GEMINI_CLI_TRUST_WORKSPACE=true`, otherwise the CLI refuses to run.
- Auth / env: `GOOGLE_GEMINI_BASE_URL` + `GEMINI_API_KEY` (persisted in user shell rc).
  Key format determines provider: `AQ.Ab8…` = Google official (base generativelanguage.googleapis.com),
  `sk-…` = cmdme relay. Mixing them causes 401.
  Note: non-interactive shells may not read rc files — call via `zsh -i -c` or explicitly export variables.
- Update: see official Gemini CLI docs for latest install command.
- Ping: `no_proxy='*' GEMINI_CLI_TRUST_WORKSPACE=true zsh -i -c 'gemini -p "reply with one word: pong"'`

## 5. Qwen

- Command: `no_proxy='*' qwen -p '<prompt>'`
- Binary lives in ~/.local/lib/qwen-code (official installer layout).
- Update: see official Qwen docs for latest install command.
- Ping: `no_proxy='*' qwen -p 'reply with one word: pong'`

## 6. Manus (External Advisor, async)

- **Privacy warning**: Sending the final draft and round summaries to Manus transmits user problem statements and internal debate content to a third-party service. Do not use Manus for debates containing proprietary, personal, or regulated data unless you have reviewed Manus's data-handling policy and obtained appropriate consent.
- Channel: Hermes Manus MCP — `mcp__manus_mcp__create_task` (deferred tool; call tool_describe first, then tool_call).
- Usage: package the final draft + round-summary synthesis into a prompt and create a task; wait for the result (async, may take minutes to tens of minutes).
- Timeout 30 min with no response → skip the advisor step; final report notes "external advisor not reviewed".
- Ping: send a minimal task "reply with one word: pong" (mode="speed"); receiving a task_id means the channel is open.
- 2026-08-12 verified: this MCP only exposes create_task / create_webhook / delete_webhook.
  **There is no tool to query task results.** Two ways to retrieve results:
  a) create_webhook to register a callback and wait for the push (used in formal debates);
  b) give the task_url to the user and ask them to paste the advisor's opinion from the Manus web UI (fallback).

## General Rules

1. All calls are non-interactive (`-p` / `exec`), no TUI; use `terminal(background=true, notify_on_complete=true)` when parallelizing.
2. Long texts go to disk; prompts only give paths.
3. Any disconnection: immediate identical retry; 2 consecutive failures → mark absent, note in final report.
4. Pre-flight `scripts/preflight.sh` is mandatory before every debate; do not start until all agents are reachable.
