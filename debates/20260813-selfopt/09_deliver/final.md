# Final Report: Conclave Self-Optimization

## Dry Conclusion

Conclave adopts a dynamic round-termination mechanism with a hard floor of R1+R2 (R3 for high-risk topics), a hard ceiling of 8 rounds, and a structured divergence ledger as the single source of truth for termination decisions. The fixed max-5-round rule is retired. Two minority opinions (Claude and Qwen) shaped the final text through specific amendments: ceiling, forced-close, structural-hold admissibility, classification appeal, and non-blocking shadow rollout.

## Consensus List

1. **Direction**: Replace fixed max-5-round with dynamic termination based on divergence state.
2. **Hard floor**: At least R1 + R2 must complete; dynamic evaluation begins no earlier than after R2.
3. **Divergence ledger**: Chair maintains a structured ledger (item ID, description, level, status, alternative, verifiable criterion, proposer, first-seen round).
4. **Termination conditions (4 required)**: (a) no open strategic/structural items; (b) no new substantive disagreements in the most recent round; (c) no admissible unresolved structural hold; (d) no user veto.
5. **Stalemate handling**: Strategic-level item stuck for 2 rounds → record as accepted-risk with triggers/rollback, or spin off a focused sub-debate (max 2 rounds).
6. **Non-blocking rollout**: Adopt immediately behind flag `convergence: dynamic`; log data per debate; review after 10 debates.

## Divergence & Adjudication

| Point | Stances | Chair Ruling |
|-------|---------|--------------|
| Hard ceiling (8 rounds) | Claude: required; Qwen: required; Others: silent | **Adopted** (Claude). Without a ceiling, non-termination risk is real. |
| Forced-close trigger | Claude: ceiling OR 2 consecutive rounds with zero new strategic/structural items | **Adopted** (Claude). Provides a clean exit when convergence stalls. |
| Structural-hold admissibility | Claude: must name affected interface/data-model/failure mode + verifiable criterion; max 2 holds per panelist; chair may overrule after 2 rounds of no new evidence | **Adopted** (Claude). Prevents free veto abuse. |
| Classification appeal | Claude: any panelist may object once per round to "restatement, not new"; forces item into ledger as open | **Adopted** (Claude). Addresses chair interest-conflict. |
| R2 termination for low-risk | Qwen: too strict; should allow acknowledgment of non-blocking parametric/executional disagreements + 5-min objection window | **Partially adopted**. Chair keeps "zero open strategic/structural" but notes that parametric/executional items are inherently non-blocking if ledger shows them as acknowledged; 5-min window is impractical for async CLI debate. |
| Shadow-mode sample size | Qwen: minimum 20, stratified, 95% CI <5%; Claude: 10 non-blocking | **Adopted 10 non-blocking** (Claude). 20 debates would delay rollout excessively; the mechanism is non-blocking, so additional data can be gathered post-adoption. Stratification is noted as a best-practice recommendation. |

## Minority Opinions (Verbatim)

**Claude (Panelist A)** — Full alternative text is preserved in `04_r3/r3_panelist_a_claude.md`. Key non-negotiables: delete any average-round target from prompts; chair proposes + no unresolved structural hold = terminate (implicit consent, not vote); ledger replaces chair summary (net token cost likely negative); shadow-mode must be non-blocking.

**Qwen (Panelist D)** — Full alternative text is preserved in `04_r3/r3_panelist_d_qwen.md`. Key concerns: cap at R8 with forced arbitration if no convergence trajectory in R6–R8; low-risk R2 termination should allow acknowledged non-blocking disagreements; shadow-mode needs 20 stratified debates with 95% CI.

## External Advisor Opinion

Manus (external advisor) was not consulted in this session due to user expectation of fast execution. Final report notes: "external advisor not reviewed."

## Absence / Exception Notes

- Gemini (Panelist C) R3 first call failed due to shell parameter-escaping issue (backticks in prompt interpreted as command substitution by `zsh -i -c`). Immediate retry via Python `subprocess` with `shlex.quote` succeeded. No content absence.
- Claude (Panelist A) R1 first call failed with "Reached max turns (1)"; retry with `--max-turns 3 --allowedTools ''` succeeded. Per updated disconnection rules, this consumed the single retry allowance.

## Adopted Text (SKILL.md Replacement)

See the `Convergence Rules` section in the updated `/Users/mac/.hermes/skills/conclave/SKILL.md`.
