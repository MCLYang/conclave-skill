#!/bin/bash
# init_debate.sh — 一键创建辩论场目录
# 用法: bash init_debate.sh <话题简称>
# 例:  bash init_debate.sh medlibya

set -e

TOPIC=${1:-}
if [ -z "$TOPIC" ]; then
  echo "用法: bash init_debate.sh <话题简称>"
  echo "  例: bash init_debate.sh medlibya"
  exit 1
fi

# 去除非法字符，限小写字母数字和连字符
TOPIC=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
if [ -z "$TOPIC" ]; then
  echo "错误: 话题简称无效，只能用英文小写、数字、连字符"
  exit 1
fi

DATE=$(date +%Y%m%d)
ROOT="$HOME/.hermes/debates"
BASE="$ROOT/bianjing-$DATE-$TOPIC"

# 检查同名冲突
if [ -d "$BASE" ]; then
  # 追加 -2, -3 等
  N=2
  while [ -d "$BASE-$N" ]; do
    N=$((N+1))
  done
  BASE="$BASE-$N"
fi

mkdir -p "$BASE"
cd "$BASE"

# 创建目录结构
mkdir -p 00_preflight 01_brief 02_r1 03_r2 04_r3 05_r4 06_r5 07_verdicts 08_signoff 09_deliver

# 创建初始文件
NOW=$(date '+%Y-%m-%d %H:%M:%S')
cat > index.md << EOF
# 辩论索引: bianjing-$DATE-$TOPIC

- 创建时间: $NOW
- 话题简称: $TOPIC
- 完整路径: $BASE

## 目录结构

| 目录 | 说明 |
|-------|------|
| 00_preflight/ | 赛前点火 |
| 01_brief/ | 立题简报 + 匿名映射 + 用户约束 |
| 02_r1/ | R1 立论 |
| 03_r2/ | R2 互驳 |
| 04_r3~06_r5/ | 收敛轮（按需创建） |
| 07_verdicts/ | 主席各轮综判 |
| 08_signoff/ | 会签草案 + 各家签罩 |
| 09_deliver/ | 终稿 + 会议纪要 |

## 时间线

| 时间 | 事件 | 文件 |
|------|------|------|
| $NOW | 辩论场创建 | 本索引 |

## 关键裁决速查

（待辩论结束后填写）
EOF

cat > 01_brief/brief.md << 'EOF'
# 立题简报

（待填写：辩题、背景、约束条件、需决策的问题）
EOF

cat > 01_brief/mapping.md << 'EOF'
# 匿名映射表

| 辩手代号 | 真实身份 | 备注 |
|-----------|----------|------|
| A | （待填写） | |
| B | （待填写） | |
| C | （待填写） | |
| D | （待填写） | |
| E | Hermes | 主席兼辩手 |
EOF

cat > 01_brief/constraints.md << 'EOF'
# 澄清环节约束

（待填写：用户的回答/裁定，每条注明对结果的塑造作用）
EOF

echo "✓ 辩论场创建成功: $BASE"
echo "  目录结构:"
find "$BASE" -maxdepth 1 -type d | sort | sed "s|$BASE/|    |"
echo ""
echo "  下一步:"
echo "    1. 填写 01_brief/brief.md"
echo "    2. 填写 01_brief/mapping.md"
echo "    3. 跑 bash ~/.hermes/skills/bianjing/scripts/preflight.sh $BASE"
