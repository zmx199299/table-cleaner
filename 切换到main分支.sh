#!/bin/bash

# 切换到 main 分支并删除远程 master 分支
# 使用方法: bash 切换到main分支.sh

echo "========================================"
echo "切换仓库到 main 分支"
echo "========================================"
echo ""

cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'

# 检查本地分支
echo "当前本地分支:"
git branch
echo ""

# 检查远程分支
echo "当前远程分支:"
git branch -r
echo ""

echo "执行以下操作:"
echo "1. 设置凭证(如果还没有)"
echo "2. 推送 main 分支到远程"
echo "3. 删除远程的 master 分支"
echo ""

read -p "准备好后按 Enter 继续..."

# 检查凭证
if [ ! -f ~/.git-credentials ]; then
    echo ""
    echo "⚠️  请先配置 GitHub 凭证"
    echo ""
    read -p "请粘贴你的 Personal Access Token: " TOKEN

    cat > ~/.git-credentials << EOF
https://zmx199299:$TOKEN@github.com
EOF

    chmod 600 ~/.git-credentials
    git config --global credential.helper store

    echo "✅ 凭证配置完成"
    echo ""
fi

# 推送 main 分支
echo "步骤 1/2: 推送 main 分支..."
git push -u origin main

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ 推送 main 分支失败!"
    exit 1
fi

echo "✅ main 分支推送成功!"
echo ""

# 删除远程 master 分支
echo "步骤 2/2: 删除远程 master 分支..."
read -p "确定要删除远程 master 分支吗? (y/n): " CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    git push origin --delete master

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ 远程 master 分支已删除!"
        echo ""
        echo "========================================"
        echo "✅ 分支切换完成!"
        echo "========================================"
        echo ""
        echo "现在 main 是主分支"
        echo ""
        echo "后续推送命令:"
        echo "git push origin main"
        echo ""
        echo "创建版本标签:"
        echo "git tag v1.0.0"
        echo "git push origin v1.0.0"
    else
        echo ""
        echo "❌ 删除 master 分支失败"
        echo "可以手动执行:"
        echo "git push origin --delete master"
    fi
else
    echo "❌ 已取消删除操作"
fi
