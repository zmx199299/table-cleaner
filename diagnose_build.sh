#!/bin/bash
# 诊断构建失败的脚本

echo "=========================================="
echo "GitHub Actions 构建诊断"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 1. 检查当前文件状态
echo "1️⃣ 检查当前文件状态"
echo "----------------------------------------"
if [ -f "assets/icon.png" ]; then
    echo "✅ icon.png 存在"
    file assets/icon.png
else
    echo "❌ icon.png 不存在"
fi

if [ -f "assets/icon.ico" ]; then
    echo "✅ icon.ico 存在"
    file assets/icon.ico
else
    echo "❌ icon.ico 不存在"
fi

if [ -f "assets/icon.icns" ]; then
    echo "✅ icon.icns 存在"
    file assets/icon.icns
else
    echo "❌ icon.icns 不存在"
fi
echo ""

# 2. 检查 Git 追踪状态
echo "2️⃣ 检查 Git 追踪状态"
echo "----------------------------------------"
git ls-files assets/
echo ""

# 3. 检查远程分支的文件
echo "3️⃣ 检查远程分支的文件(需要 git ls-remote)"
echo "----------------------------------------"
echo "最新的提交:"
git log --oneline -1
echo ""

# 4. 验证 package.json 配置
echo "4️⃣ 验证 package.json 配置"
echo "----------------------------------------"
if [ -f "package.json" ]; then
    echo "files 配置:"
    python3 -c "import json; data=json.load(open('package.json')); print('\\n'.join(data.get('build', {}).get('files', [])))"
    echo ""
    echo "图标配置:"
    python3 -c "import json; data=json.load(open('package.json')); build=data.get('build', {}); print(f\"Windows: {build.get('win', {}).get('icon', 'N/A')}\"); print(f\"macOS: {build.get('mac', {}).get('icon', 'N/A')}\"); print(f\"Linux: {build.get('linux', {}).get('icon', 'N/A')}\")"
fi
echo ""

# 5. 检查工作流文件
echo "5️⃣ 检查工作流文件"
echo "----------------------------------------"
if [ -f ".github/workflows/build.yml" ]; then
    echo "npm_script 配置:"
    grep -A 12 "include:" .github/workflows/build.yml | grep "npm_script:"
    echo ""
    echo "构建命令:"
    grep "run: npm run build" .github/workflows/build.yml
else
    echo "❌ 工作流文件不存在"
fi
echo ""

# 6. 本地测试构建命令
echo "6️⃣ 检查可用的 npm 脚本"
echo "----------------------------------------"
if command -v npm &> /dev/null; then
    echo "可用的 build 脚本:"
    npm run | grep build
else
    echo "⚠️  npm 未安装或不在 PATH 中"
fi
echo ""

# 7. 检查提交历史
echo "7️⃣ 检查最近的提交"
echo "----------------------------------------"
git log --oneline -5
echo ""

# 8. 检查标签
echo "8️⃣ 检查标签"
echo "----------------------------------------"
echo "本地标签:"
git tag -l
echo ""
echo "标签指向的提交:"
for tag in $(git tag -l); do
    echo "  $tag -> $(git rev-list -n 1 $tag) ($(git log -1 --format=%s $tag))"
done
echo ""

echo "=========================================="
echo "可能的问题和解决方案"
echo "=========================================="
echo ""

# 检查图标文件是否被 Git 追踪
if ! git ls-files assets/ | grep -q "icon"; then
    echo "❌ 问题: 图标文件未被 Git 追踪!"
    echo ""
    echo "解决方法:"
    echo "  1. 添加文件到 Git:"
    echo "     git add assets/"
    echo "  2. 提交更改:"
    echo "     git commit -m 'fix: 添加图标文件'"
    echo "  3. 推送更改:"
    echo "     git push origin main"
    echo ""
fi

# 检查图标文件格式
if [ -f "assets/icon.ico" ]; then
    if file assets/icon.ico | grep -q "PNG"; then
        echo "⚠️  警告: icon.ico 实际上是 PNG 格式"
        echo ""
        echo "electron-builder 可能不接受 PNG 格式的 .ico 文件"
        echo "建议: 使用真正的 .ico 格式文件"
        echo ""
    fi
fi

if [ -f "assets/icon.icns" ]; then
    if file assets/icon.icns | grep -q "PNG"; then
        echo "⚠️  警告: icon.icns 实际上是 PNG 格式"
        echo ""
        echo "macOS 可能不接受 PNG 格式的 .icns 文件"
        echo "建议: 使用真正的 .icns 格式文件或移除图标配置"
        echo ""
    fi
fi

echo "=========================================="
echo "推荐的修复步骤"
echo "=========================================="
echo ""
echo "如果图标文件格式不正确,建议:"
echo ""
echo "方案 1: 暂时移除图标配置"
echo "----------------------------------------"
echo "1. 编辑 package.json,注释掉 icon 配置:"
echo ""
echo '   "win": {'
echo '     "target": [{"target": "nsis", "arch": ["x64"]}]'
echo '     // "icon": "assets/icon.ico"  // 暂时注释'
echo '   }'
echo ""
echo "2. 提交并推送"
echo "3. 重新触发构建"
echo ""
echo "方案 2: 移除图标引用"
echo "----------------------------------------"
echo "1. 从 package.json 中完全删除 icon 配置"
echo "2. electron-builder 会使用默认图标"
echo ""
echo "方案 3: 创建正确的图标(推荐)"
echo "----------------------------------------"
echo "1. 使用在线工具创建真正的 .ico 和 .icns 文件"
echo "2. 参考: https://convertico.com/"
echo "3. 或使用 ImageMagick:"
echo "   convert icon.png -define icon:auto-resize=256,128,64,32,16 icon.ico"
echo ""
