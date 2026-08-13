# R3 Convergence — Panelist A (Claude)

## 立场：反对，给出完整替代文本

### 反对的具体条款与理由

**条款1：无固定上限**
无上限是最致命缺陷。终止条件2依赖"最近一轮无新的实质分歧"，但辩论参与者天然倾向持续产出新额异议——只要每轮还能造出一个新的 strategic 项，条件1和2就永远不满足。结果是把"固定5轮"的过早收敛风险，换成了无界成本+不保证终止。

**条款2：structural hold 机制**
实质上给每个 panelist 一票否决权。tag 是免费的，滥用无成本。

**条款3：chair-classified 利益冲突**
主席既是收敛提案的作者，又是"新分歧 vs 复述"的唯一裁判，存在结构性利益冲突。

**条款4：影子运行阻塞门**
8-10场影子辩论前不得采用——本次规则变更被无限期冻结。escape-defect rate 未定义可测口径，验收标准不可判定。

### 替代文本（完整版）

```
## Convergence Rules

### Round bounds
- Floor: 2 rounds (R1 + R2). High-risk topics (architecture, security,
  irreversible migration) floor: 3 rounds.
- Ceiling: 8 rounds, hard. Sub-debate rounds count toward this ceiling.
- Risk level is declared by the chair at the end of R1. If any panelist
  disputes the level, the topic is treated as high-risk. Default when
  unclear: high-risk.
- Termination evaluation begins only after the applicable floor round.

### Divergence ledger
Chair maintains after each round: item ID, description, level
(strategic / structural / parametric / executional), status
(open / resolved / suspended / accepted-risk), alternative, verifiable
resolution criterion, proposer, first-seen round.

### Termination (all four required)
1. No open strategic- or structural-level items.
2. The most recent round produced no new substantive disagreement.
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

### Classification appeal
Any panelist may object once per round to the chair's "restatement, not
new" classification. The objection forces the item into the ledger as
open; the chair must then close it on substance, not on classification.

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
```

### 核心差异
保留了动态轮次，但补上：硬上限8+强制闭合是合法终止；structural hold 的举证门槛与配额+主席可越权驳回；分类可申诉；影子验证改为非阻塞并给出可测的 escape defect 定义。
