#!/bin/bash
# 分析可能的构建失败原因

echo "=========================================="
echo "GitHub Actions 构建失败分析"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

echo "请检查以下可能的失败原因:"
echo ""

# 1. 检查 package.json 语法
echo "1️⃣ 检查 package.json 语法"
echo "----------------------------------------"
if python3 -m json.tool package.json > /dev/null 2>&1; then
    echo "✅ package.json 语法正确"
else
    echo "❌ package.json 语法错误!"
    python3 -m json.tool package.json
fi
echo ""

# 2. 检查工作流文件语法
echo "2️⃣ 检查工作流文件语法"
echo "----------------------------------------"
if [ -f ".github/workflows/build.yml" ]; then
    echo "✅ 工作流文件存在"
    echo ""
    echo "检查是否有明显的 YAML 语法问题:"
    grep -n "VERSION" .github/workflows/build.yml || echo "✅ 无 VERSION 变量残留"
    grep -n "npm run build" .github/workflows/build.yml
    echo ""
else
    echo "❌ 工作流文件不存在"
fi
echo ""

# 3. 检查 Python 文件
echo "3️⃣ 检查 Python 文件"
echo "----------------------------------------"
for pyfile in python/*.py; do
    if [ -f "$pyfile" ]; then
        echo "检查 $pyfile:"
        python3 -m py_compile "$pyfile" 2>&1 && echo "  ✅ 语法正确" || echo "  ❌ 语法错误"
    fi
done
echo ""

# 4. 检查 main.js 和 preload.js
echo "4️⃣ 检查 JavaScript 文件"
echo "----------------------------------------"
for jsfile in main.js preload.js; do
    if [ -f "$jsfile" ]; then
        echo "✅ $jsfile 存在"
    else
        echo "❌ $jsfile 不存在"
    fi
done
echo ""

# 5. 检查 renderer 目录
echo "5️⃣ 检查 renderer 目录"
echo "----------------------------------------"
if [ -d "renderer" ]; then
    echo "✅ renderer 目录存在"
    echo "  文件列表:"
    ls -la renderer/
else
    echo "❌ renderer 目录不存在"
fi
echo ""

# 6. 检查 Python 依赖
echo "6️⃣ 检查 requirements.txt"
echo "----------------------------------------"
if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt 存在"
    echo "  内容:"
    cat requirements.txt
    echo ""
    echo "检查依赖版本是否可用:"
    python3 -c "
import subprocess
try:
    import pip
    print('pip 可用')
except:
    print('⚠️  pip 不可用')
"
else
    echo "❌ requirements.txt 不存在"
fi
echo ""

# 7. 检查 package.json 的构建配置
echo "7️⃣ 检查 package.json 构建配置"
echo "----------------------------------------"
python3 << 'EOF'
import json
try:
    with open('package.json') as f:
        data = json.load(f)

    # 检查 scripts
    print("npm scripts:")
    for script in ['build:win', 'build:mac', 'build:linux']:
        if script in data.get('scripts', {}):
            print(f"  ✅ {script}: {data['scripts'][script]}")
        else:
            print(f"  ❌ {script}: 不存在")

    # 检查 build 配置
    print("\nbuild 配置:")
    build = data.get('build', {})
    print(f"  appId: {build.get('appId', 'N/A')}")
    print(f"  productName: {build.get('productName', 'N/A')}")
    print(f"  output: {build.get('directories', {}).get('output', 'N/A')}")
    print(f"  files: {len(build.get('files', []))} 项")

    # 检查目标平台
    for platform in ['win', 'mac', 'linux']:
        if platform in build:
            print(f"  {platform}: ✅ 配置存在")
            print(f"    targets: {build[platform].get('target', [])}")
        else:
            print(f"  {platform}: ❌ 配置不存在")

except Exception as e:
    print(f"❌ 错误: {e}")
EOF
echo ""

# 8. 检查 electron-builder 配置
echo "8️⃣ 检查 electron-builder 兼容性"
echo "----------------------------------------"
python3 << 'EOF'
import json
try:
    with open('package.json') as f:
        data = json.load(f)

    electron_ver = data.get('devDependencies', {}).get('electron', '')
    builder_ver = data.get('devDependencies', {}).get('electron-builder', '')

    print(f"Electron 版本: {electron_ver}")
    print(f"electron-builder 版本: {builder_ver}")

    # 检查版本兼容性
    if '30' in electron_ver:
        print("✅ Electron 30.x 是较新版本")
    if '24' in builder_ver:
        print("✅ electron-builder 24.x 兼容 Electron 30.x")

    # 检查可能的兼容性问题
    print("\n⚠️  注意事项:")
    print("1. Electron 30 可能需要 Node.js 18+")
    print("2. Windows 构建可能需要安装 wine 或使用 Windows runner")
    print("3. macOS 构建需要在 macOS runner 上进行")

except Exception as e:
    print(f"❌ 错误: {e}")
EOF
echo ""

echo "=========================================="
echo "请手动检查 GitHub Actions 日志中的错误信息"
echo "=========================================="
echo ""
echo "访问: https://github.com/zmx199299/table-cleaner/actions/runs/23045707173"
echo ""
echo "查找以下关键信息:"
echo "1. 具体是哪个步骤失败了?"
echo "2. 失败步骤的错误消息是什么?"
echo "3. 是否是 Node.js 版本问题?"
echo "4. 是否是 Python 依赖安装失败?"
echo "5. 是否是 electron-builder 构建失败?"
echo ""
echo "请将错误信息复制回来,我可以帮你分析和修复!"
echo ""
