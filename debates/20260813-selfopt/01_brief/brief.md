# Brief: Conclave Self-Optimization

## Topic
Should Conclave adopt a dynamic round-termination mechanism instead of the current fixed max-5-round rule?

## Background
Conclave currently enforces a maximum of 5 rounds (R1 positioning, R2 rebuttal, R3-R5 convergence). Field experience (2026-08-12 Libya sourcing session) shows that:
- Many objections degrade to parameter-level by R2-R3
- The most rigorous panelist (Claude in that session) kept finding deeper issues, but they were absorbable
- A full session consumes ~30-50 CLI calls and 1.5-3 wall-clock hours

## Proposal (Chair Position)
Replace the fixed "max 5 rounds" with a dynamic termination rule:
After each round, the Chair evaluates whether ALL remaining divergence points meet BOTH criteria:
1. Strategic-level disagreement is resolved (no fundamental approach conflicts remain)
2. Every objection carries an executable, verifiable alternative that can be directly absorbed

If both are met → terminate remaining rounds and proceed directly to sign-off.
Expected benefit: average rounds drop from ~4 to ~2.5, wall-clock time from 2-3h to <1h.
Expected risk: premature termination before a truly fatal flaw is uncovered.

## Decision to Make
Should this dynamic termination rule be adopted into Conclave SKILL.md as the default convergence rule?

## Constraints
- All agents must respond in Chinese
- Constructive Opposition Iron Rule applies: any objection must carry its own alternative solution
- Language: Chinese
- User expects fast execution; do not ritualize clarification
