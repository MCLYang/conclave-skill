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

## ⚠️ Security & Privacy Notice

**Before using Conclave, read this.**

1. **Local data persistence**: Every debate creates a persistent folder under `~/.hermes/debates/` containing the full brief, all agent outputs, anonymity mappings, chair verdicts, and final reports. These files remain on disk indefinitely unless you manually delete them. Do not use Conclave for topics containing regulated personal data, trade secrets, or classified information unless you accept this retention risk.

2. **External data sharing**: Panelists (Claude, Codex, Gemini, Qwen) receive debate prompts via their respective cloud APIs. The external advisor (Manus) receives the final draft and round summaries via MCP. By running a debate, you are transmitting your topic and context to these third-party AI providers. Review each provider's data policy before debating sensitive topics.

3. **Credential handling**: This skill **never** prompts for, stores, or logs passwords. The Claude Code auth section previously referenced an unsafe `security unlock-keychain -p <password>` pattern; this has been removed. Users must manually unlock the macOS keychain in an interactive terminal before background sessions.

4. **Input validation**: The `init_debate.sh` script sanitizes the topic slug to lowercase letters, digits, and hyphens only. Do not pass unsanitized user input directly into shell commands.

5. **Data retention & cleanup**: See `scripts/cleanup.sh` for automated cleanup of debates older than a configurable retention period. Run it periodically or via cron.

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

| Path | Purpose |
|------|---------|
| `00_preflight/` | Pre-flight ping results |
| `01_brief/` | Brief + anonymity mapping + user constraints |
| `02_r1/` | R1 positioning (5 agents) |
| `03_r2/` | R2 rebuttals |
| `04_r3/` | Convergence round 3 |
| `05_r4/` | Convergence round 4 |
| `06_r5/` | Convergence round 5 |
| `07_verdicts/` | Chair synthesis per round |
| `08_signoff/` | Final draft + individual votes |
| `09_deliver/` | Final report + meeting minutes |
| `index.md` | Full index: timeline, file map, key decisions |

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

## Workflow (dynamic rounds, auto-partitioned into directories)

**Step 0 Init**: `bash ~/.hermes/skills/conclave/scripts/init_debate.sh <topic-slug>` → creates `~/.hermes/debates/conclave-YYYYMMDD-<slug>/`. All subsequent files land in this directory.

```
R1 Positioning   → 5 agents in parallel, unseen by each other (prevent anchoring). Write to 02_r1/. Chair also writes a position.
R2 Rebuttal      → Each agent receives the other four's R1 (anonymized). Task: identify ≥1 fatal flaw per opponent + self-defense. Write to 03_r2/.
R3+ Convergence  → Chair synthesizes consensus/divergence into 07_verdicts/verdict_rN.md; only divergence points are sent back.
                   Each agent must "concede" or "rebut with evidence"; equivocation is prohibited. Write to 04_r3~08_signoff/.
                   Termination may occur as early as R3 if strategic divergence is resolved and every objection carries an executable alternative.
                   Hard ceiling: 8 rounds (including R1 and R2).
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

## Convergence Rules (user-mandated)

### Round bounds
- Floor: 2 rounds (R1 + R2). High-risk topics (architecture, security,
  irreversible migration) floor: 3 rounds.
- Ceiling: 8 rounds, hard. Sub-debate rounds count toward this ceiling.
- Risk level is declared by the chair at the end of R1. If any panelist
  disputes the level, the topic is treated as high-risk. Default when
  unclear: high-risk.
- Termination evaluation begins only after the applicable floor round.
- Dynamic termination: the chair may terminate early when all remaining
  divergence points are parametric/executional and every objection carries
  an executable alternative. Hard floor still applies.

### Divergence ledger
Chair maintains after each round: item ID, description, level
(strategic / structural / parametric / executional), status
(open / resolved / suspended / accepted-risk), alternative, verifiable
resolution criterion, proposer, first-seen round.

### Termination (all four required)
1. No open strategic- or structural-level items.
2. The most recent round produced no new substantive disagreement
   (chair-classified; restatements of existing disagreements do not count).
   Any panelist may object once per round to the chair's "restatement, not
   new" classification. The objection forces the item into the ledger as
   open; the chair must then close it on substance, not on classification.
3. No admissible unresolved structural hold.
4. No user veto.

### Structural hold admissibility
- A structural hold must name (a) the affected interface, data-model
  field, or failure mode, and (b) a verifiable criterion under which it
  would be resolved. A hold missing either is recorded as parametric and
  does not block termination.
- Each panelist may have at most 2 active structural holds at a time.
- Release: proposer confirms downgrade, OR another panelist seconds the
  downgrade, OR — after the same hold has been re-asserted in two
  consecutive rounds with no new evidence — the chair overrules it with a
  written reason recorded in the ledger and carried into the sign-off.

### Forced close
Trigger, whichever comes first: (a) the ceiling round is reached, or
(b) two consecutive rounds add zero new strategic- or structural-level
items. On trigger the chair closes the debate and records every remaining
open item in the sign-off as a known unresolved risk with trigger
conditions and a rollback plan. Forced close is a valid termination.

### Stalemate
An item that stays strategic-level for two consecutive rounds with no
party conceding: chair must either (a) record it as accepted-risk with
trigger conditions and rollback plan, or (b) spin off a focused
sub-debate (max 2 rounds, relevant panelists only).

### Rollout (non-blocking)
Adopt immediately behind flag `convergence: dynamic` (defaults: floor
2/3, ceiling 8). Per debate, log: rounds used; the round at which the old
5-round rule would have stopped; every strategic/structural item first
seen after round 2. Review after 10 logged debates.
Escape defect := a strategic- or structural-level item first seen in a
round that the compared rule would have cut, AND which later required a
post-sign-off change.

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

## Disconnection Rules (user-mandated: explicit retry count)

- **Per-agent per-round maximum: 2 calls** (1 original + 1 retry). No infinite retry loops.
- First failure (timeout / 401 / crash / empty output / max-turns reached) → **immediate retry**.
  - If the failure is parameter-related (e.g., Claude "Reached max turns"), **adjust the parameter first** (raise `--max-turns`, add `--allowedTools ''`, etc.) before retrying. This corrected call counts as the retry.
  - Otherwise, use an identical retry.
- Second consecutive failure → mark that agent **absent for that round**. Debate continues; final report notes absent party and reason; fix after the session, restore for the next debate.
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
4. **CLI stdout handling**: CLI stdout mixes ANSI codes and shell startup noise (local shell rc plugin errors); normalize with regex before anonymizing, otherwise read_file may judge the file binary.
5. **R1 same direction = high-confidence signal**: when five agents independently position unseen, if they independently pick the same direction / same approach, that judgment's credibility maxes out; synthesis can directly promote it to "consensus" without further debate. Conversely, points where R1 diverges are real divergence, worth spending round budget on.
6. **Session cost & pace expectation**: one full Conclave session (clarification → R1 → R2 → convergence → sign-off × N) is roughly 30-50 CLI calls, 1.5-3 wall-clock hours. Codex medium/low effort is fast enough; Claude long answers may take 10+ minutes per session. Run everything in background parallel + notify_on_complete; the chair writes its own draft while waiting.
7. **Highest-value use of audit-type panelist**: let the most rigorous panelist's (this session was Claude) objections directly rewrite final numbers, not just serve as QC — this session's six fatal arithmetic errors + one payment reallocation (breakeven 93% → 86%) all came from its opposition votes.

## Field Lessons (2026-08-13 Self-optimization session)

8. **Self-debate is valid and efficient**: Using Conclave to optimize its own SKILL.md produced actionable output in 3 rounds. The chair must be willing to concede ground when the audit-type panelist's objections are structurally sound.
9. **Shell parameter escaping is a real failure mode**: Multi-line prompts containing backticks (e.g., markdown code blocks) passed through `zsh -i -c "..."` are interpreted as command substitution by the outer shell. Use Python `subprocess` with `shlex.quote`, or strip backticks from prompts.
10. **Codex exec sandbox + shell expansion trap**: Wrapping a prompt in single quotes prevents `$(cat file)` expansion; Codex receives the literal string. Always use double quotes for shell expansion when passing file content inline.
11. **Merge minority alternatives rather than overrule**: Claude and Qwen both opposed the chair's R3 draft but provided full rewritten text. Merging their specific amendments (ceiling 8, forced close, hold admissibility, classification appeal) produced a better final rule than either the original proposal or a pure adjudication.
12. **Dynamic termination proved itself in practice**: This debate reached strategic convergence after R2; R3 functioned as a sign-off round. Total 3 rounds vs. the old fixed 5, validating the mechanism we were designing.
