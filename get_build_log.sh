#!/bin/bash
# 获取 GitHub Actions 构建日志的脚本

RUN_ID="23045099478"
REPO="zmx199299/table-cleaner"

echo "=========================================="
echo "获取 GitHub Actions 构建日志"
echo "=========================================="
echo "运行 ID: $RUN_ID"
echo "仓库: $REPO"
echo ""

# 方法1: 使用 GitHub CLI (如果已安装)
if command -v gh &> /dev/null; then
    echo "✅ 检测到 GitHub CLI,使用 gh 获取日志..."
    echo ""
    gh run view $RUN_ID --repo $REPO --log-failed
else
    echo "⚠️  未检测到 GitHub CLI"
    echo ""
    echo "请手动访问以下链接查看详细日志:"
    echo "https://github.com/$REPO/actions/runs/$RUN_ID"
    echo ""
    echo "或者安装 GitHub CLI:"
    echo "  # Linux"
    echo "  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "  echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "  sudo apt update"
    echo "  sudo apt install gh"
    echo ""
    echo "  # 安装后运行"
    echo "  gh auth login"
    echo "  gh run view $RUN_ID --repo $REPO --log-failed"
fi

echo ""
echo "=========================================="
echo "常见的 Electron 构建失败原因"
echo "=========================================="
echo ""
echo "1. Node.js 版本问题"
echo "   - 错误: 'electron-builder: Command failed'"
echo "   - 解决: 检查 package.json 中的 Node.js 版本要求"
echo ""
echo "2. 依赖安装失败"
echo "   - 错误: 'npm ERR!' 或 'ENOENT'"
echo "   - 解决: 检查 package-lock.json 是否存在"
echo ""
echo "3. Python 环境问题"
echo "   - 错误: 'python: command not found'"
echo "   - 解决: 检查工作流中 Python 安装步骤"
echo ""
echo "4. 缺少资源文件"
echo "   - 错误: 'ENOENT: no such file or directory'"
echo "   - 解决: 检查 package.json build.files 配置"
echo ""
echo "5. 平台特定问题"
echo "   - Windows: 缺少图标文件 assets/icon.ico"
echo "   - macOS: 缺少图标文件 assets/icon.icns"
echo "   - Linux: 缺少图标文件 assets/icon.png"
echo ""
echo "6. 内存不足"
echo "   - 错误: 'JavaScript heap out of memory'"
echo "   - 解决: 增加 Node.js 内存限制"
echo ""

# 检查本地项目文件
echo "=========================================="
echo "检查本地项目文件"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

if [ -f "package.json" ]; then
    echo "✅ package.json 存在"
    echo "Node 版本要求:"
    grep "engines" package.json || echo "  (未指定)"
    echo ""
fi

if [ -d "assets" ]; then
    echo "✅ assets 目录存在"
    echo "  图标文件:"
    ls -la assets/*.ico 2>/dev/null || echo "    ❌ 缺少 .ico 文件"
    ls -la assets/*.icns 2>/dev/null || echo "    ❌ 缺少 .icns 文件"
    ls -la assets/*.png 2>/dev/null || echo "    ❌ 缺少 .png 文件"
    echo ""
else
    echo "❌ assets 目录不存在"
    echo ""
fi

if [ -d "python" ]; then
    echo "✅ python 目录存在"
    echo "  Python 文件:"
    ls -la python/*.py 2>/dev/null | head -5
    echo ""
else
    echo "❌ python 目录不存在"
    echo ""
fi

if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt 存在"
    echo "  Python 依赖:"
    head -10 requirements.txt
    echo ""
else
    echo "❌ requirements.txt 不存在"
    echo ""
fi

echo "=========================================="
echo "建议的排查步骤"
echo "=========================================="
echo ""
echo "1. 访问 GitHub Actions 页面查看详细错误信息:"
echo "   https://github.com/$REPO/actions/runs/$RUN_ID"
echo ""
echo "2. 找到失败的具体步骤,查看错误日志"
echo ""
echo "3. 在本地测试相同的构建命令:"
echo "   npm ci"
echo "   npm run build:linux"
echo "   npm run build:win"
echo "   npm run build:mac"
echo ""
echo "4. 根据错误信息修复问题"
echo "5. 提交修复并重新推送标签"
echo ""
