---
name: conclave
description: "Conclave is a multi-agent reasoning skill that orchestrates multiple AI CLIs into structured debates. Each agent independently analyzes the problem, challenges competing arguments, identifies flaws and contradictions, and refines the reasoning through multiple rounds of discussion — helping you reach more reliable conclusions than relying on a single AI."
version: 1.1.0
author: Hermes Agent
metadata:
  hermes:
    tags: [Debate, Multi-Agent, Decision, Claude, Codex, Gemini, Qwen, Manus]
---

# Conclave — Multi-Agent Structured Debate & Adjudication

Given a user topic, convene five AI agents to independently posit arguments, engage in anonymous cross-examination, converge, and sign off unanimously, producing a chair-adjudicated final markdown report.

Use for high-stakes decisions (pricing structure, contract risk, architecture selection, investment judgment). Do not use for daily trivia.

## Roles

| Role | Who | Notes |
|------|-----|-------|
| Chair & Panelist | Hermes (this agent) | Moderates the session and also argues; must be impartial and must not favor any side (including itself) |
| Panelists | Claude / Codex / Gemini / Qwen | Four starting CLIs, plus Hermes makes five |
| External Advisor | Manus (MCP API, async) | Does not join regular rounds; reviews the final draft before sign-off; fatal-level objections give the chair the right to call an extra round |
| User | Human | Reviews only the final report; the anonymity mapping is transparent to the user (the user has the right to know who is who) |

## Pre-Game (mandatory before the first debate of each skill activation)

1. **Initialize the arena**: run `bash ~/.hermes/skills/conclave/scripts/init_debate.sh <topic-slug>`
   - Auto-creates `~/.hermes/debates/conclave-YYYYMMDD-<slug>/`
   - Generates the full directory structure + starter template files (brief.md / mapping.md / constraints.md / index.md)
2. **Fill the brief**: write brief.md, mapping.md, and constraints.md under `01_brief/`.
3. **Version & parameter check**: see `references/panelists.md` (commands, parameters, auth pitfalls for each agent).
4. **Pre-flight**: run `bash ~/.hermes/skills/conclave/scripts/preflight.sh <arena-path>`
   - Pings all four agents (plus Manus); results are auto-written to `00_preflight/preflight.log`.
   - Any failure: fix first (key / proxy / version), then debate.
5. **Launch the debate**: use `terminal(background=true)` to spawn the four CLIs in parallel, writing outputs to `02_r1/`.

## Arena Directory (one isolated folder per debate, auto-named)

**Root**: `~/.hermes/debates/` (persistent archive, not /tmp)
**Per-debate naming**: `conclave-<yyyymmdd>-<topic-slug>/`
  - Topic slug: 2-6 lowercase English letters/digits (e.g., `medlibya`, `pricingv2`)
  - Multiple debates on the same day append `-N` (e.g., `conclave-20260813-medlibya-2`)

**Auto-init**: run `scripts/init_debate.sh <topic-slug>` to generate the directory structure and print the path.

### Directory Structure

```
~/.hermes/debates/conclave-20260813-medlibya/
├── 00_preflight/
│   └── preflight.log          # Pre-flight ping results
├── 01_brief/
│   ├── brief.md               # Brief (read by all five agents)
│   ├── mapping.md             # Anonymity mapping (A~E ↔ identity)
│   └── constraints.md         # Clarification answers / user rulings
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
├── 04_r3/                     # Convergence rounds (created on demand)
├── 05_r4/
├── 06_r5/
├── 07_verdicts/
│   ├── verdict_r1.md          # Chair synthesis per round
│   ├── verdict_r2.md
│   └── verdict_final.md       # Final adjudication
├── 08_signoff/
│   ├── final_draft.md         # Final draft for sign-off
│   ├── signoff_claude.md
│   ├── signoff_codex.md
│   ├── signoff_gemini.md
│   ├── signoff_qwen.md
│   └── signoff_hermes.md
├── 09_deliver/
│   ├── final.md               # Final report (deliverable 1)
│   └── minutes.md             # Meeting minutes (deliverable 2)
└── index.md                   # Full index: timeline + file map + key decisions quick-reference
```

### File Discipline
- **Long texts go to disk**; prompts only give paths — do not stuff long text into command-line arguments.
- **Every round's speeches must be written to the corresponding round directory**; do not just glance at terminal stdout.
- **Chair synthesis is mandatory after every round**, written to `07_verdicts/`; otherwise panelists in the next round do not get the divergence list.
- **Final report and minutes must land in `09_deliver/`**; also copy `final.md` to the debate root for easy discovery.

## Clarification Phase (mandatory before drafting the brief)

After receiving the topic and before writing the brief, the chair self-audits: is the topic ambiguous? Is any key constraint missing from the background?
- Any unclear point / multiple reasonable interpretations → **ask the user first; no debate until answered**.
- Questions must be multiple-choice (clarify tool, 2-4 options + Other); never make the user do essay questions; ask at most 4 critical ones at a time.
- After the user answers, write brief.md; the user's answers go into the brief's "Constraints" section as shared premises for all five agents.
- If a trajectory-altering question arises mid-debate (e.g., a divergence hinges on a fact only the user knows) → the chair may pause, ask the user via clarify, append the answer to the brief, and resume.
- Do not force questions when there are none — if the topic is already clear, debate immediately; do not ritualize clarification.

## Workflow (max 5 rounds, auto-partitioned into directories)

**Step 0 Init**: `bash ~/.hermes/skills/conclave/scripts/init_debate.sh <topic-slug>` → creates `~/.hermes/debates/conclave-YYYYMMDD-<slug>/`. All subsequent files land in this directory.

```
R1 Positioning   → 5 agents in parallel, unseen by each other (prevent anchoring). Write to 02_r1/. Chair also writes a position.
R2 Rebuttal      → Each agent receives the other four's R1 (anonymized). Task: identify ≥1 fatal flaw per opponent + self-defense. Write to 03_r2/.
R3-R5 Convergence → Chair synthesizes consensus/divergence into 07_verdicts/verdict_rN.md; only divergence points are sent back.
                   Each agent must "concede" or "rebut with evidence"; equivocation is prohibited. Write to 04_r3~06_r5/.
```

Round reference files:
- `02_r1/` for each agent's positioning
- `03_r2/` for rebuttal speeches
- `07_verdicts/verdict_rN.md` for chair synthesis
- `08_signoff/final_draft.md` for sign-off draft
- `09_deliver/final.md` + `minutes.md` for final deliverables

Constructive Opposition Iron Rule (user-mandated, applies to all rounds):
- **Any objection / rebuttal must carry its own solution** — "what do you think is the correct approach?", executable, verifiable.
- Objection + reason without solution = invalid speech; the chair names and sends it back for rewrite; it does not count toward the round's output.
- When rebutting others in R2, you must give "how would you fix it"; in R3-R5, alternatives and new evidence are both mandatory.

Convergence Rules (user-mandated):
- Max 5 rounds (including R1 and R2).
- If divergence points drop to zero after any round → go straight to sign-off.
- If objections remain after Round 5 → **chair mandatory adjudication**, minority opinions appended verbatim to the final report.

Sign-off (not counted as a round):
- Final draft sent to all five agents; each may only reply `Agree` or `Oppose + specific clause + specific reason + own alternative`.
- **Destruction without construction = invalid vote (user-mandated)**: opposition must give an executable alternative; votes lacking one are void, treated as abstentions, and the chair proceeds with the remaining valid votes.
- Unanimous pass → external advisor review.
- Opposition & rounds remain → extra round targeting the objection reason and alternative; rounds exhausted → chair adjudicates, alternative appended to minority opinion.

External Advisor (Manus):
- Send final draft + round summaries; ask: any fatal-level objections?
- If yes → chair judges: valid → extra round (if rounds exhausted, disclose the objection and adjudication reason in the final); invalid → written rejection with reason in the final.
- If no → deliver.

## Anonymity Rules

- In R2 rebuttals and convergence rounds, all speeches are signed "Panelist A~E"; no identity clues allowed.
- mapping.md is generated by the chair and kept secret for the session; the user may inspect it at any time.
- Chair synthesis quotes only "Panelist X"; the final report may disclose real-name stances (user requests transparency).

## Disconnection Rules (user-mandated: retry immediately)

- Any agent call failure in any round (timeout / 401 / crash) → **immediate identical retry**.
- 2 consecutive failures → mark that agent absent for that round; debate continues; final report notes absent party and reason; fix after the session, restore for the next debate.
- Chair (Hermes) never disconnects; Manus advisor timeout 30 min → skip advisor, final report notes "external advisor not reviewed".

## Language Rule (user-mandated)

- The debate language must match the user's current session language. The chair sets this in the brief's `Language` field.
- All five agents (including the chair) must output in that language; English defaults are overridden.
- If the user switches language mid-session, the brief is updated and all subsequent rounds follow the new language.

## Parameter Rules

- Codex default `-c model_reasoning_effort="medium"` (cost/speed balance); user calls "important session" for xhigh.
- Codex exec is a read-only sandbox; file writes are rejected → prompts must require "full text to stdout", and the chair extracts from process logs to disk.
- Claude uses `-p --max-turns 1`; Gemini uses `-p`; Qwen uses `-p`. All non-interactive; no TUI.
- Prompts for the five agents are identical word-for-word except the role sentence, ensuring fairness.

## Deliverables (two items, both mandatory)

### 1. final.md (decision document, `09_deliver/final.md`)
1. **First paragraph: dry conclusion**. 3-5 sentences in plain language: what is the final opinion, what to do, one key risk. No fluff, no jargon stacking.
2. Consensus list (items all five agents agree on).
3. Divergence & adjudication: each point → each agent's stance (real name disclosed) → chair ruling + reason.
4. Minority opinions (if any) verbatim appendix.
5. External advisor opinion and handling result.
6. Absence / exception notes (if any).

### 2. minutes.md (process document, `09_deliver/minutes.md`)
Recap how the debate reached the final report:
1. Opening: topic + clarification answers / rulings + how each shaped the outcome.
2. Roster & anonymity mapping (real names disclosed).
3. Round-by-round evolution: R1 five-way stance comparison → R2 what got killed (who struck) → R3-R5 how divergence closed → sign-off round what each objection turned into.
4. Kill list: rejected solutions / categories + cause of death + who struck.
5. Agent contributions & evaluation (real names).
6. Minority opinion archive.
7. File index (source paths per round).

Give the user the absolute paths of `09_deliver/final.md` and `09_deliver/minutes.md`, and paste the first paragraph of final in the reply.

### 3. index.md (debate root directory)
After each debate, auto-generate `index.md` in the debate root:
- Topic, date, participants
- Timeline: R1 → R2 → convergence → sign-off → advisor, timestamps per step
- File map: pointers to round sources
- Key decision quick-reference
- Info usable for `@session` restarts

This index lets the user find key decisions in 10 seconds even after 3 months.

## Chair Neutrality Red Line

- Synthesis must not weight a point just because the chair proposed it; chair views struck down must still be recorded under "rejected positions".
- Rulings must cite round-source evidence (file + line number); no impressions allowed.
- If the user disagrees with a ruling → the user's word is the supreme arbiter; the chair writes the user's opinion into the final report marked "user adjudication".

## Field Lessons (2026-08-12 Libya sourcing session)

1. **External advisor opinions must carry a version number**: Manus reviewed an old draft; half its opinions were already resolved — attach a version number when sending the advisor task, and require the first line of the opinion to state the reviewed version; otherwise you waste a round.
2. **Audit-type panelist (e.g., Claude) objection depth increases per round**: structure → parameters → footnotes, always able to dig deeper. The chair must adjudicate closure when "objections have degraded to parameter-level and alternatives are directly absorbable"; otherwise there is no convergence. Closure standard: no strategic-level divergence + all objections have absorbable alternatives.
3. **`claude -p --max-turns 1` occasionally reports "Reached max turns"**: when retrying per disconnection rules, raise `--max-turns` to 3-10 (add `--allowedTools ''` to prevent spinning); do not stick to the original parameter.
4. **CLI output cleaning**: CLI stdout mixes ANSI codes and shell startup noise (local .zshrc conda plugin errors); clean with regex before anonymizing, otherwise read_file may judge the file binary.
5. **R1 same direction = high-confidence signal**: when five agents independently position unseen, if they independently pick the same direction / same approach, that judgment's credibility maxes out; synthesis can directly promote it to "consensus" without further debate. Conversely, points where R1 diverges are real divergence, worth spending round budget on.
6. **Session cost & pace expectation**: one full Conclave session (clarification → R1 → R2 → convergence → sign-off × N) is roughly 30-50 CLI calls, 1.5-3 wall-clock hours. Codex medium/low effort is fast enough; Claude long answers may take 10+ minutes per session. Run everything in background parallel + notify_on_complete; the chair writes its own draft while waiting.
7. **Highest-value use of audit-type panelist**: let the most rigorous panelist's (this session was Claude) objections directly rewrite final numbers, not just serve as QC — this session's six fatal arithmetic errors + one payment reallocation (breakeven 93% → 86%) all came from its opposition votes.
