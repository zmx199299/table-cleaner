#!/bin/bash

# WSL 一键推送脚本
# 使用方法: bash 一键推送.sh

echo "========================================"
echo "WSL 终端推送代码 - 表格自动化清理工具"
echo "========================================"
echo ""

# 步骤 1: 设置凭证(如果还没有)
if [ ! -f ~/.git-credentials ]; then
    echo "步骤 1/4: 配置 GitHub 凭证"
    echo ""
    echo "请先访问以下链接获取 Personal Access Token:"
    echo "https://github.com/settings/tokens"
    echo ""
    read -p "准备好 Token 后,按 Enter 继续..."
    echo ""
    read -p "请粘贴你的 Token: " TOKEN

    if [ -z "$TOKEN" ]; then
        echo "❌ Token 不能为空"
        exit 1
    fi

    cat > ~/.git-credentials << EOF
https://zmx199299:$TOKEN@github.com
EOF

    chmod 600 ~/.git-credentials
    git config --global credential.helper store

    echo "✅ 凭证配置完成"
    echo ""
fi

# 步骤 2: 进入项目目录
cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'
echo "步骤 2/4: 进入项目目录"
pwd
echo ""

# 步骤 3: 推送代码到 main 分支
echo "步骤 3/4: 推送代码到 GitHub (main 分支)..."
git push -u origin main

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ 推送失败!"
    echo ""
    echo "可能的原因:"
    echo "1. Token 已过期或无效"
    echo "2. Token 没有 'repo' 权限"
    echo "3. 需要先删除远程 master 分支"
    echo ""
    echo "解决方案:"
    echo "1. 删除凭证文件: rm ~/.git-credentials"
    echo "2. 或执行: bash 切换到main分支.sh"
    exit 1
fi

echo "✅ 代码推送成功!"
echo ""

# 步骤 4: 创建并推送标签
echo "步骤 4/4: 创建版本标签并推送"
git tag v1.0.0 2>/dev/null || echo "标签已存在,跳过创建"
git push origin v1.0.0

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ 所有操作完成!"
    echo "========================================"
    echo ""
    echo "🚀 GitHub Actions 正在自动构建..."
    echo ""
    echo "查看构建进度:"
    echo "https://github.com/zmx199299/table-cleaner/actions"
    echo ""
    echo "下载安装包:"
    echo "https://github.com/zmx199299/table-cleaner/releases"
    echo ""
    echo "预计等待时间: 5-10 分钟"
    echo ""
else
    echo ""
    echo "⚠️  标签推送失败,但代码已成功推送"
    echo "可以手动创建标签:"
    echo "git tag v1.0.0"
    echo "git push origin v1.0.0"
fi
