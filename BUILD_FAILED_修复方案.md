# GitHub Actions 构建失败问题分析与修复

## 🔴 构建失败原因分析

经过全面排查,发现以下导致构建失败的问题:

### 问题 1: 缺少图标文件 ❌
**位置**: `assets/` 目录

**问题描述**:
- `assets/icon.ico` 不存在
- `assets/icon.icns` 不存在  
- `assets/icon.png` 不存在

**影响**:
- `package.json` 中配置了图标路径:
  ```json
  "win": { "icon": "assets/icon.ico" }
  "mac": { "icon": "assets/icon.icns" }
  "linux": { "icon": "assets/icon.png" }
  ```
- electron-builder 在构建时会查找这些文件,找不到会报错

**解决方案**:
- ✅ 已创建占位符图标文件(70 字节的 PNG 格式)
- ⚠️  注意: 目前是临时方案,正式版本需要使用真正的图标
- 后续可以使用在线工具或专业设计软件创建更专业的图标

---

### 问题 2: 工作流中未定义 VERSION 变量 ❌
**位置**: `.github/workflows/build.yml:25, 29`

**问题描述**:
```yaml
artifact_name: 表格自动化清理工具 Setup ${VERSION}.exe  # VERSION 未定义!
artifact_name: 表格自动化清理工具-${VERSION}.dmg         # VERSION 未定义!
```

**影响**:
- `${VERSION}` 会被解析为空字符串
- 导致 artifact_name 变量错误
- 可能影响构建产物的命名

**解决方案**:
- ✅ 改用 `${{ github.ref_name }}` 获取标签名
- 修复后:
  ```yaml
  artifact_name: 表格自动化清理工具-${{ github.ref_name }}-setup.exe
  artifact_name: 表格自动化清理工具-${{ github.ref_name }}.dmg
  ```

---

### 问题 3: package.json 未包含 assets 目录 ❌
**位置**: `package.json:40-46`

**问题描述**:
```json
"files": [
  "main.js",
  "package.json",
  "python/**",
  "preload.js",
  "renderer/**"
  // 缺少 "assets/**"
]
```

**影响**:
- 构建时不会打包 assets 目录
- 导致图标文件不会包含在最终安装包中

**解决方案**:
- ✅ 添加 `"assets/**"` 到 files 数组
- 修复后:
  ```json
  "files": [
    "main.js",
    "package.json",
    "python/**",
    "preload.js",
    "renderer/**",
    "assets/**"
  ]
  ```

---

## ✅ 已完成的修复

### 1. 创建图标文件
```bash
cd assets
# 创建占位符图标(使用系统图标或透明 PNG)
cp /usr/share/pixmaps/gnome-terminal.png icon.png
cp icon.png icon.ico
cp icon.png icon.icns
```

**文件状态**:
- ✅ `assets/icon.png` - 70 字节
- ✅ `assets/icon.ico` - 70 字节(临时使用 PNG 格式)
- ✅ `assets/icon.icns` - 70 字节(占位符)

### 2. 修复工作流变量
```diff
- artifact_name: 表格自动化清理工具 Setup ${VERSION}.exe
+ artifact_name: 表格自动化清理工具-${{ github.ref_name }}-setup.exe

- artifact_name: 表格自动化清理工具-${VERSION}.dmg
+ artifact_name: 表格自动化清理工具-${{ github.ref_name }}.dmg
```

### 3. 更新 package.json
```diff
  "files": [
    "main.js",
    "package.json",
    "python/**",
    "preload.js",
    "renderer/**",
+   "assets/**"
  ],
```

---

## 🚀 推送修复后的代码

### 方法 1: 正常推送(网络恢复后)
```bash
cd /mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理

# 添加所有更改
git add .

# 提交
git commit -m "fix: 添加图标文件,修复工作流中的VERSION变量问题"

# 推送
git push origin main
```

### 方法 2: 使用代理(如果网络问题持续)
```bash
# 设置代理(替换为你的代理地址)
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 推送
git push origin main

# 推送后取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### 方法 3: 手动上传到 GitHub
1. 访问: https://github.com/zmx199299/table-cleaner
2. 点击 "Add file" -> "Upload files"
3. 上传以下文件:
   - `assets/icon.png`
   - `assets/icon.ico`
   - `assets/icon.icns`
4. 编辑 `.github/workflows/build.yml`
5. 编辑 `package.json`
6. 提交更改

---

## 🔄 重新触发构建

### 方法 1: 重新推送标签
```bash
cd /mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理

# 删除旧标签
git tag -d v1.0.0

# 创建新标签(指向最新提交)
git tag v1.0.0

# 强制推送标签
git push origin v1.0.0 --force
```

### 方法 2: 推送新版本标签
```bash
# 创建新版本标签
git tag v1.0.1

# 推送新标签
git push origin v1.0.1
```

### 方法 3: 手动触发工作流
1. 访问: https://github.com/zmx199299/table-cleaner/actions
2. 点击 "Build and Release" 工作流
3. 点击右侧 "Run workflow" 按钮
4. 选择分支 `main`
5. 点击 "Run workflow"

---

## 📊 预期的构建产物

修复后,构建成功应该产生以下产物:

### Windows
- `表格自动化清理工具-v1.0.0-setup.exe` - NSIS 安装程序

### macOS
- `表格自动化清理工具-v1.0.0.dmg` - DMG 镜像文件

### Linux
- `表格自动化清理工具-v1.0.0.AppImage` - AppImage 便携应用
- `表格自动化清理工具-v1.0.0.deb` - Debian 包

---

## 🔍 可能的其他问题

### 问题: Python 依赖安装失败

**症状**: 
```
ERROR: Could not find a version that satisfies the requirement pandas==2.2.0
```

**解决**: 更新 requirements.txt 中的版本号

### 问题: Node.js 缓存问题

**症状**:
```
Cache not found for input keys: node-18, linux...
```

**解决**: 清除缓存或在 Actions 中禁用缓存

### 问题: electron-builder 构建超时

**症状**:
```
Error: Build timed out after 3600000ms
```

**解决**: 
- 优化构建流程
- 减少不必要的文件
- 使用 GitHub Actions 的 timeout 选项

---

## 📝 后续改进建议

### 1. 创建专业的图标
使用以下工具创建更好的图标:
- **Windows (.ico)**: 使用 GIMP 或在线工具
- **macOS (.icns)**: 在 macOS 上使用 iconutil
- **Linux (.png)**: 使用 GIMP 或 Inkscape

推荐图标尺寸:
- .ico: 256x256, 128x128, 64x64, 32x32, 16x16
- .icns: 512x512, 256x256, 128x128, 64x64, 32x32
- .png: 512x512

### 2. 添加构建前的验证步骤
在 workflow 中添加:
```yaml
- name: Validate project files
  run: |
    if [ ! -f "assets/icon.ico" ]; then
      echo "Error: assets/icon.ico not found"
      exit 1
    fi
    if [ ! -f "assets/icon.icns" ]; then
      echo "Error: assets/icon.icns not found"
      exit 1
    fi
    if [ ! -f "assets/icon.png" ]; then
      echo "Error: assets/icon.png not found"
      exit 1
    fi
```

### 3. 添加本地构建测试
```bash
# 本地测试构建
npm ci
npm run build:linux
npm run build:win  # 在 Windows 上
npm run build:mac  # 在 macOS 上
```

### 4. 优化构建流程
- 使用缓存加速构建
- 并行化独立的构建任务
- 添加构建通知

---

## 📚 参考文档

- [electron-builder 官方文档](https://www.electron.build/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Electron 图标最佳实践](https://www.electronjs.org/docs/latest/tutorial/code-signing)

---

## 📌 修复记录

**日期**: 2026-03-13  
**构建 ID**: 23045099478  
**主要问题**: 
1. 缺少图标文件
2. VERSION 变量未定义
3. assets 目录未包含在 package.json

**修复内容**:
1. ✅ 创建占位符图标文件
2. ✅ 修复工作流中的变量引用
3. ✅ 更新 package.json 包含 assets

**待完成**:
- ⏳ 推送修复到 GitHub(网络恢复后)
- ⏳ 重新触发构建
- ⏳ 验证构建产物
- ⏳ 创建专业的图标文件(可选)

---

*Created by zmx199299 with CodeBuddy-CN*
