#!/bin/bash
# GitHub Actions 构建问题排查脚本

echo "=========================================="
echo "GitHub Actions 构建问题排查"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 1. 检查当前 Git 状态
echo "1️⃣ 检查当前 Git 状态"
echo "----------------------------------------"
git status
echo ""

# 2. 检查本地标签
echo "2️⃣ 检查本地标签"
echo "----------------------------------------"
git tag -l
echo ""

# 3. 检查远程标签
echo "3️⃣ 检查远程标签"
echo "----------------------------------------"
git ls-remote --tags origin
echo ""

# 4. 检查当前分支
echo "4️⃣ 检查当前分支"
echo "----------------------------------------"
git branch --show-current
echo ""

# 5. 检查工作流文件
echo "5️⃣ 检查工作流文件"
echo "----------------------------------------"
if [ -f ".github/workflows/build.yml" ]; then
    echo "✅ 工作流文件存在"
    echo ""
    echo "触发条件:"
    grep -A 5 "^on:" .github/workflows/build.yml | head -6
else
    echo "❌ 工作流文件不存在"
fi
echo ""

# 6. 检查 package.json 脚本
echo "6️⃣ 检查 package.json 构建脚本"
echo "----------------------------------------"
if [ -f "package.json" ]; then
    echo "可用的构建脚本:"
    grep -A 10 '"scripts"' package.json | grep 'build'
    echo ""
    echo "当前版本:"
    grep '"version"' package.json
else
    echo "❌ package.json 不存在"
fi
echo ""

# 7. 检查与远程的同步状态
echo "7️⃣ 检查与远程的同步状态"
echo "----------------------------------------"
echo "本地分支:"
git branch -vv
echo ""
echo "远程分支:"
git branch -r
echo ""

# 8. 检查最近的提交
echo "8️⃣ 检查最近的提交"
echo "----------------------------------------"
git log --oneline -5
echo ""

# 9. 诊断结果和建议
echo "=========================================="
echo "📋 诊断结果和建议"
echo "=========================================="
echo ""

# 检查是否有 v1.0.0 标签
if git rev-parse v1.0.0 >/dev/null 2>&1; then
    echo "✅ 本地存在 v1.0.0 标签"
else
    echo "❌ 本地不存在 v1.0.0 标签"
    echo "   建议执行: git tag v1.0.0"
fi

# 检查标签是否推送到远程
if git ls-remote --tags origin | grep -q "refs/tags/v1.0.0"; then
    echo "✅ 远程存在 v1.0.0 标签"
else
    echo "❌ 远程不存在 v1.0.0 标签"
    echo "   建议执行: git push origin v1.0.0"
fi

echo ""
echo "🔧 下一步操作建议:"
echo "----------------------------------------"
echo "1. 如果标签不存在,创建并推送:"
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0"
echo ""
echo "2. 如果标签已存在但未触发,手动触发工作流:"
echo "   访问: https://github.com/zmx199299/table-cleaner/actions"
echo "   点击 'Build and Release' -> 'Run workflow'"
echo ""
echo "3. 检查 GitHub Actions 权限设置:"
echo "   Settings > Actions > General > Workflow permissions"
echo "   确保选择了 'Read and write permissions'"
echo ""
