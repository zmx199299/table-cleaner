# GitHub Actions 常见构建错误及解决方案

## 📋 请先查看错误日志

访问: https://github.com/zmx199299/table-cleaner/actions/runs/23045707173

找到失败的步骤和错误信息,然后参考下面的解决方案。

---

## ❌ 错误 1: Python 依赖安装失败

### 错误信息示例:
```
ERROR: Could not find a version that satisfies the requirement pandas==2.2.0
ERROR: No matching distribution found for pandas==2.2.0
```

### 解决方案:
放宽版本限制,使用更灵活的版本号:

**修改 requirements.txt**:
```diff
- pandas==2.2.0
+ pandas>=2.0.0
- openpyxl==3.1.2
+ openpyxl>=3.0.0
- python-dateutil==2.8.2
+ python-dateutil>=2.8.0
```

**提交修改**:
```bash
git add requirements.txt
git commit -m "fix: 放宽 Python 依赖版本限制"
git push origin main
git tag v1.0.3
git push origin v1.0.3
```

---

## ❌ 错误 2: Node.js 版本不兼容

### 错误信息示例:
```
Error: The engine "node" is incompatible with this module.
Expected version ">=18.0.0"
```

### 解决方案 1: 修改 package.json 添加 Node.js 引擎要求:
```json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### 解决方案 2: 降低 Electron 版本:
```json
{
  "devDependencies": {
    "electron": "^28.0.0",
    "electron-builder": "^24.13.3"
  }
}
```

---

## ❌ 错误 3: electron-builder 构建失败

### 错误信息示例 3.1: 缺少文件
```
Error: ENOENT: no such file or directory, open 'python/data_cleaner.py'
```

**解决**: 检查 package.json 的 files 配置是否包含所有必需文件

### 错误信息示例 3.2: Python Shell 问题
```
Error: spawn python3 ENOENT
```

**解决**: 在 package.json 中添加 Python 路径配置:
```json
{
  "build": {
    "extraMetadata": {
      "main": "main.js"
    },
    "asarUnpack": [
      "python/**"
    ]
  }
}
```

### 错误信息示例 3.3: 平台特定问题
```
Error: Application entry file "main.js" does not exist
```

**解决**: 确保 main.js 在正确的位置,并在 files 配置中包含

---

## ❌ 错误 4: npm ci 失败

### 错误信息示例:
```
Error: npm ERR! Missing lockfile: package-lock.json required when running npm ci
```

**解决方案**: 生成 package-lock.json
```bash
npm install
git add package-lock.json
git commit -m "chore: 添加 package-lock.json"
git push origin main
```

---

## ❌ 错误 5: Windows 构建失败 (wine 相关)

### 错误信息示例:
```
wine: cannot find /usr/bin/wine
```

**解决方案**: Windows 构建必须在 Windows runner 上进行,检查工作流配置:
```yaml
- os: windows-latest
```
这应该是正确的,因为 matrix 已经包含 windows-latest

---

## ❌ 错误 6: macOS 代码签名问题

### 错误信息示例:
```
Error: Code signing is required for product type 'Application'
```

**解决方案**: 在 package.json 中禁用代码签名:
```json
{
  "build": {
    "mac": {
      "identity": null,
      "hardenedRuntime": false
    }
  }
}
```

---

## ❌ 错误 7: Linux 构建失败

### 错误信息示例:
```
Error: EACCES: permission denied, open '/usr/bin/fpm'
```

**解决方案**: electron-builder 应该自动处理 fpm,如果失败可以:
1. 添加 AppImage 目标(已配置)
2. 添加 deb 目标(已配置)
3. 或只使用 AppImage

---

## ❌ 错误 8: 内存不足

### 错误信息示例:
```
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
```

**解决方案**: 在工作流中增加 Node.js 内存限制:
```yaml
- name: Build application
  run: |
    export NODE_OPTIONS="--max-old-space-size=4096"
    npm run build:${{ matrix.npm_script }}
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## ❌ 错误 9: Python 虚拟环境问题

### 错误信息示例:
```
ModuleNotFoundError: No module named 'pandas'
```

**解决方案**: 确保在构建时激活虚拟环境。但 electron-builder 不会自动激活虚拟环境。

**更好的方案**: 在本地打包 Python 依赖,或使用 pyinstaller

**临时方案**: 修改 package.json,在 postinstall 脚本中安装 Python 依赖:
```json
{
  "scripts": {
    "postinstall": "pip3 install --user -r requirements.txt"
  }
}
```

---

## ❌ 错误 10: npm cache 问题

### 错误信息示例:
```
Cache not found for input keys: node-18, linux...
```

**解决方案**: 临时禁用缓存:
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18'
    # cache: 'npm'  # 注释掉缓存
```

---

## 🔧 快速诊断步骤

### 步骤 1: 本地测试构建
```bash
cd /mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理

# 清理旧构建
rm -rf dist node_modules package-lock.json

# 重新安装
npm install

# 测试构建
npm run build:linux
```

### 步骤 2: 检查详细错误
```bash
# 查看完整的构建输出
npm run build:linux 2>&1 | tee build.log

# 查看日志
cat build.log
```

### 步骤 3: 最小化配置测试
创建一个最小的 package.json 测试:
```json
{
  "name": "test-electron",
  "version": "1.0.0",
  "main": "main.js",
  "scripts": {
    "build:linux": "electron-builder --linux"
  },
  "devDependencies": {
    "electron": "^30.0.0",
    "electron-builder": "^24.13.3"
  }
}
```

---

## 📞 如果以上都不行

请提供以下信息:
1. 完整的错误日志(从失败的步骤开始)
2. 哪个平台的构建失败了?(Windows/macOS/Linux)
3. 是否所有平台都失败,还是只有特定平台?

或者尝试:
1. **手动触发工作流**: 在 GitHub Actions 页面点击 "Run workflow"
2. **只构建一个平台**: 修改工作流,注释掉其他平台
3. **查看 Actions 日志的最底部**: 通常会有完整的堆栈跟踪

---

## 📌 已知的当前配置状态

✅ **正确配置**:
- package.json 语法正确
- 所有必需文件存在
- Python 文件语法正确
- npm 脚本配置正确
- 工作流文件语法正确
- Electron 和 electron-builder 版本兼容

⚠️ **需要注意**:
- Python 依赖使用了固定版本 (可能需要放宽)
- 没有 package-lock.json (可能需要生成)
- electron-builder 需要正确处理 Python 依赖

---

*Created by zmx199299 with CodeBuddy-CN*
*Date: 2026-03-13*
