# Conclave Consensus Protocol v1.0

Chair-audited revision of the v0.1 architecture proposal. Highest objective: **decision quality, not consensus**.

Status legend: **[CORE]** = implemented in current workflow · **[V1]** = implementable now, added by this protocol · **[L2]** = requires data/infrastructure, deferred · **[HEURISTIC]** = no rigorous basis yet; must be labeled as such in every output.

---

## 0. What was rejected from v0.1 and why

| v0.1 item | Verdict | Reason |
|---|---|---|
| §13 w̃ᵢ = wᵢ/(1+λΣρᵢⱼwⱼ) | **REJECTED** | Ad hoc. The statistically principled aggregation of correlated estimators is inverse-covariance (GLS) weighting: w* ∝ Σ⁻¹1. Anything else needs empirical justification we don't have. |
| §17 Priority = I × D × U (product) | **REJECTED** | Product of three [0,1] terms collapses all priorities into noise. Replaced by decision-relevance-first ranking (§5 below). |
| §20 literal EVSI | **REPLACED** | True EVSI needs a likelihood model over what a new agent would say — intractable. Replaced by computable proxy: Decision-Flip Value (§6). |
| §3 fixed 7-model council | **BLOCKED** | Only 4 panelist CLIs exist (Claude, Codex, Gemini, Qwen) + Hermes + Manus. Seed/DeepSeek/Grok are not available. See §2. |
| §29C full calibration DB | **SCOPED** | Most strategic decisions never receive ground truth; Brier scores are uncomputable for them. Calibration tracking is restricted to *verifiable predictions* only (§9). |
| Multiplicative weight wᵢ = hᵢ·rᵢ·qᵢ | **[HEURISTIC]** kept with defaults | No calibration data yet. Default hᵢ = 1 for all; rᵢ, qᵢ set by chair per debate, logged, never presented as precise. |

## 1. Objective

a* = argmin_a E[L(a,θ) | E] + λ·Cost(process)

Consensus is an intermediate statistic, never the target. The chair optimizes the decision under a loss function the USER must supply or approve (default for investments: expected percentage drawdown of the account).

## 2. Modes (resource-constrained reality)

| Mode | Panelists | When | Manus |
|---|---|---|---|
| Quick | 2 CLIs + Hermes | low-risk, fast | off by default |
| Standard | 4 CLIs + Hermes | default (current implementation) | trigger-based (§7) |
| Deep | **BLOCKED** until additional panelist CLIs (DeepSeek/Grok/etc.) are installed and pass preflight | high-stakes | preferred |

Mode selection is declared by the chair in the brief; the user may override.

## 3. Round structure [CORE + V1]

- **R1 independence is absolute [CORE]**: no panelist sees another's output. Prompts identical except the explicit role-letter assignment (field lesson 13).
- **Structured R1 output [V1]**: each panelist must return JSON-ish blocks: position, claims[], evidence[], assumptions[], uncertainties[], disconfirming_conditions[], recommended_action, and self-rated confidence. Free-text reasoning follows the block. Confidence is self-reported and therefore **discounted, never trusted at face value**.
- R2+ cross-examination, constructive-opposition iron rule, anonymity, disconnection rules: unchanged [CORE].

## 4. Claim-based synthesis [V1]

The chair decomposes positions into atomic claims C₁…Cₙ (target 4–8 claims). For each claim the chair records: supporters, opponents, evidence sources cited, and **source overlap** (two agents citing the same URL/fact = one independent piece of evidence, not two). This replaces the v0.1 "evidence graph" with a flat table the chair can actually maintain in a verdict file.

## 5. Divergence triage [V1] — replaces v0.1 §17

Rank claims by **decision relevance first**:

1. Flip test: if P(Cₖ) moved across its decision threshold, would the recommended action change? If no → deprioritize regardless of disagreement volume.
2. Among decision-relevant claims, sort by divergence (spread of panelist positions).
3. Among those, sort by whether additional evidence is obtainable at all.

Only the top 1–2 claims enter the next round's prompt. This is the operational form of "find the uncertainty most worth resolving" (v0.1 §18).

## 6. Stopping rule [V1] — Decision-Flip Value (DFV), the computable EVSI proxy

Continue only if there exists an open claim Cₖ such that:

P(resolving Cₖ flips the decision) × E[loss reduction if flipped] > Cost(next round)

Estimation is deliberately crude: chair assigns the flip probability from the divergence ledger; loss reduction from the user's loss function; round cost ≈ 4–6 CLI calls ≈ 20–40 min wall time. All three numbers are **[HEURISTIC]** and must be logged in the verdict. Hard floors/ceilings from the current convergence rules (floor 2/3, ceiling 8) remain as guardrails.

## 7. Manus external advisor [V1 — upgraded by field lesson 16]

Manus is External Advisor, never a voter. Retrieval via direct REST polling (POST/GET api.manus.im/v1/tasks), ~3 min turnaround.

Trigger conditions (any one):
- T1: a decision-relevant claim depends on verifiable real-world facts the council cannot check;
- T2: R1 unanimity with suspected correlated training data (all four CLIs are LLMs — herding is the default failure mode);
- T3: critical minority dissent (§8);
- T4: the topic is time-sensitive (prices, regulation, news).

Manus output is treated as **evidence**, weighted by verifiability of its sources — not as an opinion. Chair audits: does each claim carry a checkable source? Unsourced Manus assertions get weight ≈ one self-rated LLM claim.

## 8. Dissent & critical minority [CORE + V1]

Existing sign-off rules (opposition requires an executable alternative; minority opinions archived verbatim) remain. Addition: dissent triage by expected loss Dᵢ = P(Fᵢ) × Impact(Fᵢ), where P(Fᵢ) is **discounted** because it is self-reported by the dissenter (default discount ×0.5, [HEURISTIC]). If Dᵢ > 10% of the decision's expected value at stake, the dissent forces one targeted follow-up round or a Manus reality check — never silently dropped.

## 9. Aggregation math [V1]

For binary/probability questions, until calibration data exists:

1. Convert each panelist's position on the claim to pᵢ (extracted from structured output; missing → claim excluded from pooling).
2. Normalize weights: ŵᵢ = wᵢ / Σw (prevents extremization).
3. Correlation discount: N_eff = (Σŵᵢ)² / ΣᵢΣⱼ ŵᵢŵⱼρᵢⱼ with default ρ = 0.6 same-family / 0.3 cross-family **[HEURISTIC]**; report N_eff alongside every pooled number.
4. Pool in log-odds with prior z₀ = logit(0.5) unless the user supplies a base rate: z* = z₀ + Σŵᵢ(zᵢ − z₀), then p* = σ(z*). Label output "uncalibrated pooled estimate".
5. **[L2]** When ≥30 resolved verifiable predictions exist: switch to inverse-covariance (GLS) weights from realized error correlations, and fit a recalibration map (Platt or isotonic) on pooled outputs. Not before.

## 10. Verdict schema [V1]

final.md keeps its current mandatory structure (dry conclusion first, consensus list, divergence & adjudication, minority verbatim, advisor handling). Added fields:

- Mode used; N_eff (with heuristic label); claim table with per-claim status (resolved / open / accepted-risk); stopping reason (which rule fired); dissent expected-loss triage results; every heuristic number explicitly tagged.

## 11. Calibration logging [V1]

Every debate appends one JSONL record to `~/.hermes/debates/calibration.jsonl`: debate id, date, and every **verifiable** prediction extracted from the final report (subject, predicted value/range/probability, check date). Only predictions with a defined check date and an observable outcome are recorded. A cron job (or the chair at the next debate) resolves due predictions and computes running Brier/calibration per agent. Non-verifiable judgments are never scored — pretending to score them is worse than not scoring.

## 12. What this protocol deliberately does NOT do

- No dynamic expansion mid-debate [L2].
- No learned ρᵢⱼ [L2].
- No Bayesian Model Averaging / hierarchical Bayes [L2 — unjustifiable without calibration data; would be fake precision].
- No claim that any pooled probability is calibrated before the log has data.
