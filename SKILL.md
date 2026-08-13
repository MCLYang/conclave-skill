---
name: conclave
description: "Conclave is a multi-agent reasoning skill that orchestrates multiple AI CLIs into structured debates. Each agent independently analyzes the problem, challenges competing arguments, identifies flaws and contradictions, and refines the reasoning through multiple rounds of discussion — helping you reach more reliable conclusions than relying on a single AI."
version: 1.1.0
author: Hermes Agent
metadata:
  hermes:
    tags: [Debate, Multi-Agent, Decision, Claude, Codex, Gemini, Qwen, Manus]
---

# Conclave（辩经）— 多Agent结构化辩论与裁决

就用户给定话题，召集五家 AI 各自立论 → 匿名互驳 → 收敛 → 全会签，产出一份主席裁决过的终稿 md 报告。
用于高 stakes 决策（定价结构、合同风险、架构选型、投资判断），不要用于日常琐事。

## 角色

| 角色 | 谁 | 说明 |
|------|-----|------|
| 主席兼辩手 | Hermes（本 agent） | 主持全场 + 自己也下场立论；必须公正客观，不得偏袒任何一方（包括自己） |
| 辩手 | Claude / Codex / Gemini / Qwen | 首发四家 CLI，与 Hermes 共五家 |
| 外援顾问 | Manus（MCP API，异步） | 不进常规轮次；终稿会签前把草案给它审一次，有硬伤级反对 → 主席有权加赛一轮 |
| 用户 | 人 | 只看终稿；匿名映射表对用户透明（用户有权知道谁是谁） |

## 赛前（每次启用该 skill 的第一场辩论前必做）

1. **初始化辩论场**：跑 `bash ~/.hermes/skills/bianjing/scripts/init_debate.sh <话题简称>`
   - 自动在 `~/.hermes/debates/` 下创建 `bianjing-YYYYMMDD-<简称>/`
   - 生成完整目录结构 + 初始模板文件（brief.md / mapping.md / constraints.md / index.md）
2. **填写简报**：在 `01_brief/` 下写好 brief.md、mapping.md、constraints.md。
3. **版本与参数检查**，见 `references/panelists.md`（每家调用命令、参数、auth 坑）。
4. **点火试验**：跑 `bash ~/.hermes/skills/bianjing/scripts/preflight.sh <辩论场路径>`
   - 四家（含 Manus）各 ping 一次，结果自动落盘到 `00_preflight/preflight.log`。
   - 任何一家不通：先修（key/代理/版本），修好再辩。
5. **发起辩论**：用 `terminal(background=true)` 并行发起四家 CLI，落盘到 `02_r1/` 目录。

## 辩论场目录（每场独立文件夹，自动命名）

**根目录**：`~/.hermes/debates/`（持久化存档，非 /tmp）
**单场命名**：`bianjing-<yyyymmdd>-<话题简称>/`
  - 话题简称取 2-6 个英文小写字母/数字（如 `medlibya`、`pricingv2`）
  - 若同天多场，追加 `-N`（如 `bianjing-20260813-medlibya-2`）

**自动初始化**：跑 `scripts/init_debate.sh <话题简称>`，一键生成目录结构并输出路径。

### 目录结构

```
~/.hermes/debates/bianjing-20260813-medlibya/
├── 00_preflight/
│   └── preflight.log          # 赛前点火结果
├── 01_brief/
│   ├── brief.md               # 立题简报（五家同读）
│   ├── mapping.md             # 匿名映射表（A~E ↔ 身份）
│   └── constraints.md         # 澄清环节用户答案/裁定
├── 02_r1/
│   ├── r1_hermes.md
│   ├── r1_claude.md
│   ├── r1_codex.md
│   ├── r1_gemini.md
│   └── r1_qwen.md
├── 03_r2/
│   ├── r2_claude.md
│   ├── r2_codex.md
│   ├── r2_gemini.md
│   └── r2_qwen.md
├── 04_r3/                     # 收敛轮（按需创建）
├── 05_r4/
├── 06_r5/
├── 07_verdicts/
│   ├── verdict_r1.md          # R1 主席综判
│   ├── verdict_r2.md
│   └── verdict_final.md       # 终局裁决
├── 08_signoff/
│   ├── final_draft.md         # 终稿草案
│   ├── signoff_claude.md
│   ├── signoff_codex.md
│   ├── signoff_gemini.md
│   ├── signoff_qwen.md
│   └── signoff_hermes.md
├── 09_deliver/
│   ├── final.md               # 终稿（交付物一）
│   └── minutes.md             # 辩论纪要（交付物二）
└── index.md                   # 全场索引：时间线 + 文件地图 + 关键裁决速查
```

### 文件纪律
- **长文一律落盘**，prompt 里只给路径——不要把长文塞进命令行参数。
- **每轮发言必须落盘到对应轮次目录**，禁止只在终端 stdout 里看看就算。
- **主席综判每轮必出**，写进 `07_verdicts/`，否则下轮辩手拿不到分歧点清单。
- **终稿和纪要必须进 `09_deliver/`**，同时把 `final.md` 复制到辩论根目录方便查找。

## 澄清环节（立题之前，用户钦定必做）

拿到话题后、写简报之前，主席先自审：话题有没有歧义？背景缺不缺关键约束？
- 有任何不清楚/有多种合理解读 → **先问用户，不问不开辩**。
- 提问一律用选择题（clarify 工具，给 2-4 个选项 + Other），不让用户做问答题；一次最多问 4 个最关键的。
- 用户答完再写 brief.md；用户的回答原文写进简报"约束条件"章节，作为五家共同前提。
- 辩论进行中（任何一轮后）若冒出影响走向的疑问（如分歧点取决于一个只有用户知道的事实）→ 主席可叫停，同样用选择题问用户，答案追加进简报后继续。
- 没疑问不许硬问——话题已经清楚就直接开辩，别拿澄清当仪式感。

## Workflow（最多 5 轮，每场自动分目录落盘）

**Step 0 初始化**：`bash ~/.hermes/skills/bianjing/scripts/init_debate.sh <话题简称>`→生成 `~/.hermes/debates/bianjing-YYYYMMDD-<简称>/`。后续所有文件都落在这个目录里。

```
R1 立论   五家并行，互不见面（防锚定）。落盘到 02_r1/ 目录。主席自己也写一份立论。
R2 互驳   每家拿到其余四家的 R1（已匿名），任务：逐家指出 ≥1 个硬伤 + 自辩。落盘到 03_r2/ 。
R3-R5 收敛  主席每轮后出综判（共识点/分歧点），写进 07_verdicts/verdict_rN.md；只把分歧点打回，
          每家必须"让步"或"举证反驳"，禁止和稀泥。落盘到 04_r3~06_r5/ 。
```

每轮简报的文件参照：
- `02_r1/` 各家立论
- `03_r2/` 互驳发言
- `07_verdicts/verdict_rN.md` 主席综判
- `08_signoff/final_draft.md` 会签草案
- `09_deliver/final.md` + `minutes.md` 最终交付物

建设性反对铁律（用户钦定，适用所有轮次）：
- **任何反对/驳斥必须附带自己的解决方案**——"你认为正确的做法是什么"，可执行、可验证。
- 只提反对+理由不给方案 = 无效发言，主席点名打回重写，不计入该轮成果。
- R2 驳斥别家硬伤时就要给"如果是你会怎么改"；R3-R5 反驳时替代方案与新证据并列必须。

收敛规则（用户钦定）：
- 最多 5 轮（含 R1、R2）。
- 任一轮结束后若分歧点清零 → 直接进会签。
- 第 5 轮结束仍有异议 → **主席强制裁决**，少数派意见原样附在终稿末尾。

会签（不算轮次）：
- 终稿草案发五家，每家只许回 `同意` 或 `反对+具体条款+具体理由+自己的替代方案`。
- **只破不立=无效票（用户钦定）**：反对必须同时给出"你认为应该怎么改/怎么做"的可执行替代方案；只反对不给方案的票作废，视同未表态，主席按其余有效票推进。
- 全票通过 → 外援顾问审阅。
- 有反对且轮次未满 → 针对反对理由与替代方案加赛一轮；轮次已满 → 主席裁决，替代方案原文附入少数派意见。

外援顾问（Manus）：
- 终稿草案 + 各轮纪要摘要发给它，问一句：有无硬伤级反对意见。
- 有 → 主席判断：成立则加赛一轮（若轮次已满则在终稿中披露该反对意见并给出裁决理由）；不成立则书面驳回，理由写进终稿。
- 无 → 交付。

## 匿名纪律

- R2 互驳及收敛轮中，所有发言一律以"辩手A~E"署名，禁止透露真实身份线索。
- mapping.md 主席生成、全场保密；用户随时可查。
- 主席综判引用观点时也只称"辩手X"，终稿里可实名披露各家立场（用户要求透明）。

## 断线纪律（用户钦定：断线立即重来）

- 任一家任一轮调用失败（超时/401/崩溃）→ **立即原样重发该次调用**。
- 连续重试 2 次仍失败 → 该家该轮记"缺席"，辩论继续，终稿注明缺席方与原因；赛后修复，下一场恢复首发。
- 主席自身（Hermes）不存在断线；Manus 顾问超时 30 分钟无响应 → 跳过顾问环节，终稿注明"外援未审"。

## 参数纪律

- Codex 默认 `-c model_reasoning_effort="medium"`（成本/速度平衡）；用户点名"重要场次"才用 xhigh。
- Codex exec 是只读沙箱，写文件必被拒——提示词里必须要求"全文输出到 stdout"，主席从进程日志提取落盘。
- Claude 用 `-p --max-turns 1`；Gemini 用 `-p`；Qwen 用 `-p`。全部非交互，禁止 TUI。
- 五家提示词除了角色句外逐字相同，保证公平。

## 交付物（两样，缺一不可）

### 1. 终稿 final.md（决策文件，落盘 `09_deliver/final.md`）
1. **第一段：干货结论**。3-5 句说人话：最终意见是什么、怎么做、关键风险一个。禁止铺垫、禁止术语堆砌。
2. 共识点清单（五家一致同意的）。
3. 分歧与裁决：每个分歧点 → 各家立场（实名披露）→ 主席裁决 + 理由。
4. 少数派意见（如有）原文附录。
5. 外援顾问意见及处理结果。
6. 缺席/异常情况说明（如有）。

### 2. 会议纪要 minutes.md（过程文件，落盘 `09_deliver/minutes.md`）
复盘整场辩论怎么走到终稿的：
1. 开局：辩题 + 澄清环节用户答案/裁定 + 每条对结果的塑造作用。
2. 阵容与匿名映射（实名披露）。
3. 各轮演化：R1 五家立场对照表 → R2 打掉了什么（谁开的刀）→ R3-R5 分歧怎么收的 → 会签每轮反对票变成了什么改进。
4. 阵亡名单：被选掉的方案/品类 + 死因 + 谁开的刀。
5. 各家贡献与评价（实名）。
6. 少数派意见归档。
7. 文件索引（各轮原文路径）。

把 `09_deliver/final.md` 与 `09_deliver/minutes.md` 的绝对路径给用户，final 第一段同步贴在回复里。

### 3. 索引 index.md（落盙8 辩论根目录）
每场辩论结束后，在辩论根目录自动生成 `index.md`：
- 辩题、日期、参与方
- 时间线：R1→R2→收敛→会签→外援，每步时间戳
- 文件地图：指向各轮原文
- 关键裁决速查表
- 下次重启时能用 `@session` 引用的信息

这个索引文件让用户在 3 个月后还能 10 秒找到当时的关键决策。

## 主席公正性红线

- 综判时不得因某观点是主席自己提的而加权；主席观点被驳倒一样要写进"被否决观点"。
- 裁决必须引用各轮原文证据（文件+行号），不许凭印象。
- 用户对裁决不服 → 用户的话是最高裁决，主席把用户意见写进终稿并标注"用户裁定"。

## 实战教训（2026-08-12 利比亚选品场沉淀）

1. **外援意见必须带版本号**：Manus 审的是旧版草案，半条意见已被解决——发顾问任务时附上版本号，要求意见书首行注明所审版本，否则白裁决一轮。
2. **审计型辩手（如 Claude）的反对深度随轮次递增**：从结构→参数→脚注，永远能再挖出东西。主席必须在"反对已降级为参数级、且替代方案可直接吸收"时裁决收束，否则收敛不了。收束标准：没有战略层分歧 + 所有反对都有可吸收的替代方案。
3. **claude -p --max-turns 1 偶尔报 "Reached max turns"**：断线纪律重试时把 --max-turns 提到 3-10（加 --allowedTools '' 防空转），别死磕原参数。
4. **CLI 输出清洗**：各 CLI stdout 混 ANSI 码和 shell 启动噪音（本机 .zshrc 的 conda 插件报错），落盘后用正则清洗再匿名化，否则 read_file 判二进制。
5. **R1 撞方向=高可信信号**：五家互不见面立论，若独立选中同一方向/同一打法，该判断可信度直接拉满，综判时可直接升入"共识"，不必再辩；反之 R1 就分叉的点才是真分歧，值得把轮次预算花在那。
6. **场次成本与节奏预期**：一场完整 Conclave（辩经）（澄清→R1→R2→收敛→会签×N）约 30-50 次 CLI 调用、1.5-3 小时墙钟。Codex 用 medium/low effort 够快；Claude 长答案单场可能 10 分钟+，全部后台并行 + notify_on_complete，主席自己的稿子趁等待时写。
7. **审计型辩手价值密度最高的用法**：让最严谨的辩手（本场是 Claude）的反对意见直接改写终稿数字，而不是只当质检——本场六处致命算术错误 + 一次货款重配（打平点 93%→86%）全来自它的反对票。
