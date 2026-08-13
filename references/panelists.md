# 辩手花名册（panelists）

五家首发 + 一家外援。所有 CLI 调用前加 `no_proxy='*'`（本机系统代理指向已关闭的 127.0.0.1:7897，不走代理才稳）。

## 1. Hermes（主席兼辩手）

- 就是本 agent 自己。立论/互驳由主席在同会话内撰写，与其他四家同等格式落盘。
- 红线：不得偏袒自己，被驳倒照样进"被否决观点"。

## 2. Claude Code

- 命令：`no_proxy='*' claude -p '<prompt>' --max-turns 1`
- auth：官方 OAuth（zhang@testsprite.com），凭证在 macOS 登录钥匙串。
  后台会话读钥匙串可能被锁（security exit 36）→ 先跑
  `security unlock-keychain -p <密码> ~/Library/Keychains/login.keychain-db`（用户给密码）。
  若仍 401：检查并移开旧的 ~/.claude/.credentials.json 再试。
- 更新：`claude update`
- 点火：`no_proxy='*' claude -p 'reply with one word: pong' --max-turns 1`

## 3. Codex

- 命令：`no_proxy='*' codex exec --skip-git-repo-check -c model_reasoning_effort="medium" '<prompt>'`
  重要场次把 medium 换成 xhigh。
- auth：cmdme.cn 中转，~/.codex/auth.json 里的 sk- key；config.toml 里
  `requires_openai_auth = false`、`wire_api = "responses"`、`base_url = "https://cmdme.cn"`。
- 坑：exec 默认只读沙箱，写盘必被拒 → prompt 必须要求"全文输出到 stdout"，
  主席用 `process(action='log', offset=0, limit=400)` 提取落盘。
- 更新：`codex update`
- 点火：`no_proxy='*' codex exec --skip-git-repo-check 'reply with one word: pong'`

## 4. Gemini CLI

- 命令：`no_proxy='*' GEMINI_CLI_TRUST_WORKSPACE=true zsh -i -c 'gemini -p "<prompt>"'`
- 坑：0.55.1 起新增信任目录检查，非交互调用必须带 `GEMINI_CLI_TRUST_WORKSPACE=true`，否则直接拒跑。
- auth/env：`GOOGLE_GEMINI_BASE_URL` + `GEMINI_API_KEY`（持久化在 ~/.zshrc）。
  key 格式定归属：`AQ.Ab8…`=Google 官方（base 用 generativelanguage.googleapis.com），
  `sk-…`=cmdme 中转。混搭必 401。
  注意：Hermes 持久 bash 不读 .zshrc——调用前先 `env | grep -i gemini` 确认，
  没有就用 `zsh -i -c 'gemini -p ...'` 或显式补 env。
- 更新：`npm install -g @google/gemini-cli@latest`
- 点火：`no_proxy='*' GEMINI_CLI_TRUST_WORKSPACE=true zsh -i -c 'gemini -p "reply with one word: pong"'`

## 5. Qwen

- 命令：`no_proxy='*' qwen -p '<prompt>'`
- 本体在 ~/.local/lib/qwen-code（官方安装脚本布局）。
- 更新：`bash -c "$(curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen.sh)"`
- 点火：`no_proxy='*' qwen -p 'reply with one word: pong'`

## 6. Manus（外援顾问，异步）

- 通道：Hermes 的 Manus MCP——`mcp__manus_mcp__create_task`（deferred tool，先 tool_describe 再 tool_call）。
- 用法：终稿草案 + 各轮综判摘要打包成 prompt 发一个 task，等结果（异步，可能几分钟到几十分钟）。
- 超时 30 分钟无响应 → 跳过顾问环节，终稿注明"外援未审"。
- 点火：发一个 "reply with one word: pong" 的最小 task（mode="speed"），能建单拿回 task_id 即通。
- 2026-08-12 实测：该 MCP 只有 create_task / create_webhook / delete_webhook 三件，
  **没有查询任务结果的工具**。取结果的两种方式：
  a) create_webhook 注册回调等推送（正式辩论用）；
  b) 把 task_url 给用户，请用户在 Manus 网页里把顾问意见贴回来（兜底）。

## 通用规则

1. 全部非交互（`-p` / `exec`），禁止 TUI；需要并行时用 `terminal(background=true, notify_on_complete=true)`。
2. 长文落盘，prompt 只给路径。
3. 任一家断线：立即原样重发；连续 2 次失败记缺席，终稿注明。
4. 赛前必跑 `scripts/preflight.sh`，五家全通才开辩。
