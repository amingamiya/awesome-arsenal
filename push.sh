#!/usr/bin/env bash
# 一键把本目录推到你的 GitHub 账号 amingamiya/awesome-arsenal
#
# 前置条件：本机装了 Git for Windows / git
# 用法：bash push.sh
#
# 首次运行会弹出浏览器要求授权 GitHub 账号（Git Credential Manager 流程），
# 授权后自动完成 push。后续更新再跑一次即可。

set -euo pipefail

REPO="https://github.com/amingamiya/awesome-arsenal.git"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$DIR"

if [ ! -d ".git" ]; then
  echo ">> 初始化本地仓库"
  git init
  git branch -M main
fi

echo ">> 写入忽略规则"
cat > .gitignore <<'EOF'
.DS_Store
Thumbs.db
*.tmp
EOF

git add -A
git -c user.name="aming" -c user.email="2281210248@qq.com" commit -m "feat: 分类收藏 121 个热门 GitHub 项目（实用/爬虫/逆向/安全/好玩/自托管）"

echo ">> 推送到 $REPO"
git push -u "$REPO" main

echo ""
echo "完成。仓库地址：$REPO"
