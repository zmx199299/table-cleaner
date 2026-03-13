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
echo "步骤 1/3: 同步远程仓库..."
git fetch origin

echo "步骤 2/3: 推送 main 分支..."
# 尝试正常推送
if ! git push -u origin main 2>/dev/null; then
    echo ""
    echo "⚠️  正常推送失败,尝试强制推送..."
    echo ""
    read -p "是否使用强制推送? 这会覆盖远程仓库的内容 (y/n): " FORCE_PUSH
    
    if [ "$FORCE_PUSH" = "y" ] || [ "$FORCE_PUSH" = "Y" ]; then
        git push -u origin main --force
        
        if [ $? -eq 0 ]; then
            echo "✅ main 分支强制推送成功!"
        else
            echo "❌ 推送失败!"
            exit 1
        fi
    else
        echo "❌ 推送已取消"
        exit 1
    fi
else
    echo "✅ main 分支推送成功!"
fi
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
