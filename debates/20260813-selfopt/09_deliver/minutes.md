# Meeting Minutes: Conclave Self-Optimization Debate

## Opening

- **Topic**: Should Conclave adopt dynamic round-termination instead of fixed max-5-round?
- **Date**: 2026-08-13
- **Clarification**: None required; topic was self-contained.

## Roster & Anonymity Mapping

| Code | Real Identity | Role |
|------|---------------|------|
| A | Claude Code | Panelist |
| B | Codex | Panelist |
| C | Gemini CLI | Panelist |
| D | Qwen | Panelist |
| E | Hermes (this agent) | Chair & Panelist |

## Round-by-Round Evolution

### R1 Positioning
- **A (Claude)**: Conditional support. Reject "average 2.5 rounds" as target and chair single-point judgment. Proposed divergence ledger, R3 floor, new-divergence-rate→0, in-round slimming, shadow run.
- **B (Codex)**: Conditional support. Four thresholds: minimum R2, divergence ledger with levels, opponent confirmation, risk grading.
- **C (Gemini)**: Conditional support. Two safety valves: opponent confirmation + N+1 verification round for new alternatives.
- **D (Qwen)**: Conditional support. Three safety valves: minimum 2 rounds, joint veto right (1 per panelist per debate), 48-hour cooling rollback.
- **E (Chair)**: Conditional support. Three constraints: hard floor R1+R2, strategic/parametric criteria written into SKILL.md, user retains veto.

### R2 Rebuttal
- Chair synthesized 3 strategic divergences: (1) floor R2 vs R3, (2) chair single-point vs decentralized decision, (3) include "no new disagreements" as termination condition.
- **A** defended R3 floor (last-word bias), rejected chair single-point (asymmetric cost of false-stop vs false-continue), insisted on ledger + implicit consent.
- **B** supported R3 floor, rejected pure chair single-point and pure mechanical veto, supported "no new disagreements" as hard condition.
- **C** defended R2 floor (R2 is already cross-examination), rejected full decentralization as bureaucratic overload, rejected mechanical "no new disagreement" as prone to meta-debate.
- **D** defended R2 floor but added "earliest termination evaluation after R3", proposed three-party check (chair + opponent + user), supported "no new disagreement" with chair classification + provenance check.
- **E (Chair)** shifted toward A: accepted R3 conservative default, accepted ledger + hold mechanism, accepted "no new disagreements".

### R3 Convergence (Chair Proposal + Sign-off Style)
- Chair issued a consolidated convergence text.
- **B**: Agree.
- **C**: Agree.
- **A**: Oppose + full rewritten text. Key additions: hard ceiling 8, forced-close trigger, structural-hold admissibility rules, classification appeal, non-blocking shadow rollout.
- **D**: Oppose 3 clauses + alternatives. Key additions: cap at R8 with forced arbitration, relaxed low-risk R2 termination, 20 stratified shadow debates with 95% CI.

## Kill List

| Rejected Item | Cause of Death | Who Struck |
|---------------|----------------|------------|
| Fixed max-5-round | All 5 panelists agreed it wastes resources | Consensus |
| "Average 2.5 rounds" as target | Goodhart risk, drives performative convergence | A (Claude) |
| Chair single-point termination | Structural interest conflict | A (Claude) |
| Pure mechanical vote/veto | Bureaucratic overload, voting fatigue | C (Gemini) |
| 48-hour cooling rollback | Impractical for async CLI debate | Not adopted; E ruled it out-of-scope |
| N+1 verification round for every new alternative | Absorbed into structural-hold rules | E (Chair) |

## Agent Contributions & Evaluation

- **Claude (A)**: Deepest objections, most detailed alternative text. Six fatal-level observations reshaped the final draft: ceiling, forced-close, hold admissibility, classification appeal, shadow rollout definition, escape-defect metric.
- **Codex (B)**: Fast, cost-aware. Provided the four-threshold framework that became the backbone of the convergence rules.
- **Gemini (C)**: Balanced, broad coverage. Safety-valve framing (opponent confirmation + N+1) was absorbed into hold and appeal mechanisms.
- **Qwen (D)**: Direct, execution-focused. Forced-arbitration and stratified shadow sampling improved robustness; 48-hour rollback was deemed impractical.
- **Hermes (E)**: Chair. Maintained neutrality, shifted position when evidence warranted, synthesized final text.

## Minority Opinion Archive

- See `04_r3/r3_panelist_a_claude.md` for Claude's full alternative.
- See `04_r3/r3_panelist_d_qwen.md` for Qwen's full alternative.

## File Index

| Round | File |
|-------|------|
| Brief | `01_brief/brief.md`, `01_brief/mapping.md` |
| R1 | `02_r1/r1_panelist_a_claude.md`, `r1_panelist_b_codex.md`, `r1_panelist_c_gemini.md`, `r1_panelist_d_qwen.md`, `r1_panelist_e_hermes.md` |
| R2 | `03_r2/r2_panelist_e_hermes.md` (Chair only; other panelist outputs extracted from process logs) |
| R3 | `04_r3/r3_panelist_a_claude.md`, `r3_panelist_b_codex.md`, `r3_panelist_c_gemini.md`, `r3_panelist_d_qwen.md` |
| Verdicts | `07_verdicts/verdict_r1.md`, `verdict_r2.md`, `verdict_r3.md` |
| Deliverables | `09_deliver/final.md`, `minutes.md` |
