# GitHub Actions 构建问题排查指南

## 📋 问题分析

经过全面排查,发现以下导致构建任务未触发的问题:

### 🔴 主要问题

1. **npm 脚本命名不匹配**
   - **工作流调用**: `npm run build:${{ matrix.platform }}`
   - **实际变量值**: `platform` 为 `windows`, `mac`, `linux`
   - **package.json 脚本**: `build:win`, `build:mac`, `build:linux`
   - **问题**: `build:windows` 不存在 ❌

2. **标签在修复前推送**
   - 原始 v1.0.0 标签指向的是旧的提交
   - 工作流文件修复后的代码未被包含
   - 需要重新触发构建

### ✅ 已修复

1. 添加 `npm_script` 变量到 matrix 配置
2. 将 `platform: windows` 改为 `npm_script: win`
3. 将 `build:${{ matrix.platform }}` 改为 `build:${{ matrix.npm_script }}`

---

## 🔧 完整排查步骤

### 步骤 1: 检查标签状态
```bash
cd /mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理

# 检查本地标签
git tag -l

# 检查远程标签
git ls-remote --tags origin
```

### 步骤 2: 检查工作流文件
```bash
# 查看工作流文件内容
cat .github/workflows/build.yml

# 验证触发条件
grep -A 5 "^on:" .github/workflows/build.yml
```

### 步骤 3: 检查 package.json 脚本
```bash
# 查看所有 build 脚本
grep -A 10 '"scripts"' package.json | grep build
```

### 步骤 4: 检查 GitHub Actions 权限设置

访问你的 GitHub 仓库:
1. 进入仓库 Settings
2. 左侧菜单选择 "Actions" -> "General"
3. 滚动到 "Workflow permissions" 部分
4. 确保选择:
   - ✅ **Read and write permissions**
   - ✅ Allow GitHub Actions to create and approve pull requests
5. 点击 "Save" 保存

### 步骤 5: 手动触发工作流(可选)

如果自动触发不成功,可以手动触发:
1. 访问: https://github.com/zmx199299/table-cleaner/actions
2. 点击 "Build and Release" 工作流
3. 点击右侧 "Run workflow" 按钮
4. 选择分支 `main`
5. 点击绿色的 "Run workflow" 按钮

---

## 🚀 重新触发构建

### 方法 1: 重新推送标签(推荐)
```bash
cd /mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理

# 删除本地标签
git tag -d v1.0.0

# 重新创建标签(指向最新提交)
git tag v1.0.0

# 强制推送标签
git push origin v1.0.0 --force
```

### 方法 2: 推送新标签
```bash
# 创建新版本标签
git tag v1.0.1

# 推送新标签
git push origin v1.0.1
```

### 方法 3: 手动触发
在 GitHub Actions 页面手动运行工作流

---

## 📊 监控构建进度

1. 访问 Actions 页面:
   ```
   https://github.com/zmx199299/table-cleaner/actions
   ```

2. 查看运行状态:
   - 🟡 Queued: 排队中
   - 🟢 In progress: 运行中
   - ✅ Success: 成功
   - ❌ Failed: 失败

3. 点击运行记录查看详细日志

---

## 🔍 常见问题排查

### 问题 1: 构建失败 - npm ci 错误

**原因**: Node.js 版本不匹配或依赖问题

**解决**:
```bash
# 本地测试构建
npm ci
npm run build:win    # Windows
npm run build:mac    # macOS
npm run build:linux  # Linux
```

### 问题 2: 构建失败 - Python 安装错误

**原因**: Python 环境配置问题

**解决**: 检查工作流中 Python 安装步骤
```yaml
- name: Install Python
  run: |
    if [ "$RUNNER_OS" == "Linux" ]; then
      sudo apt-get update
      sudo apt-get install -y python3 python3-pip python3-venv
    elif [ "$RUNNER_OS" == "macOS" ]; then
      brew install python@3.10
    fi
  shell: bash
```

### 问题 3: 构建失败 - 资源文件未找到

**原因**: package.json 的 `build.files` 配置不正确

**检查**:
```json
"files": [
  "main.js",
  "package.json",
  "python/**",
  "preload.js",
  "renderer/**"
]
```

确保所有必需文件都被包含

### 问题 4: 工作流没有触发

**检查清单**:
- ✅ 标签格式是否正确(必须是 v*.*.*)
- ✅ 工作流文件是否在 `.github/workflows/` 目录下
- ✅ YAML 语法是否正确
- ✅ 是否有权限运行 Actions

---

## 📝 工作流配置说明

### 触发条件
```yaml
on:
  push:
    tags:
      - 'v*.*.*'  # 只有推送 v1.0.0, v2.1.3 等格式的标签才触发
  workflow_dispatch:  # 允许手动触发
```

### 构建矩阵
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    include:
      - os: ubuntu-latest
        platform: linux
        npm_script: linux        # ✅ 修复: 明确指定 npm 脚本名
      - os: windows-latest
        platform: windows
        npm_script: win          # ✅ 修复: 使用 win 而非 windows
      - os: macos-latest
        platform: mac
        npm_script: mac
```

### 构建步骤
```yaml
steps:
  - Checkout code         # 检出代码
  - Setup Node.js         # 设置 Node.js
  - Install dependencies   # 安装 npm 依赖
  - Install Python        # 安装 Python
  - Setup venv            # 创建虚拟环境
  - Build application     # 构建应用
  - Upload artifact       # 上传构建产物
  - Create Release        # 创建 Release
```

---

## 🎯 验证修复是否成功

### 1. 检查 Actions 页面
访问: https://github.com/zmx199299/table-cleaner/actions

查看是否有新的运行记录

### 2. 检查构建产物
如果构建成功,可以在以下位置找到产物:
- **Actions 运行记录**: 滚动到底部的 Artifacts 区域
- **Releases 页面**: https://github.com/zmx199299/table-cleaner/releases

### 3. 下载并测试
下载对应的安装包:
- Windows: `.exe` 文件
- macOS: `.dmg` 文件
- Linux: `.AppImage` 或 `.deb` 文件

---

## 📞 获取帮助

如果问题仍未解决,请:

1. 查看完整的 Actions 运行日志
2. 运行排查脚本:
   ```bash
   ./check_actions.sh
   ```
3. 检查 GitHub 官方文档:
   - https://docs.github.com/en/actions
   - https://docs.github.com/en/actions/learn-github-actions/triggering-a-workflow

---

## 📌 修复记录

**日期**: 2026-03-13  
**问题**: GitHub Actions 构建未触发  
**根本原因**: npm 脚本命名不匹配 + 标签在修复前推送  
**解决方案**:
1. 添加 `npm_script` 变量
2. 修正 npm 脚本名称映射
3. 重新推送 v1.0.0 标签

**相关提交**: `20a0ed6` - fix: 修复工作流中 npm 脚本命名不匹配问题,添加排查脚本

---

*Created by zmx199299 with CodeBuddy-CN*
