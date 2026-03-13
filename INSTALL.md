# 安装指南

## 系统要求

- **操作系统**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)
- **Node.js**: 18.0.0 或更高版本
- **Python**: 3.10 或更高版本

## 开发环境安装

### 1. 安装 Node.js

#### Windows
1. 访问 [Node.js 官网](https://nodejs.org/)
2. 下载并安装 LTS 版本
3. 验证安装:
   ```cmd
   node --version
   npm --version
   ```

#### macOS
使用 Homebrew 安装:
```bash
brew install node
```

#### Linux (Ubuntu/Debian)
```bash
# 使用 NodeSource 仓库安装
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node --version
npm --version
```

### 2. 安装 Python

#### Windows
1. 访问 [Python 官网](https://www.python.org/downloads/)
2. 下载 Python 3.10 或更高版本
3. 安装时勾选 "Add Python to PATH"
4. 验证安装:
   ```cmd
   python --version
   pip --version
   ```

#### macOS
使用 Homebrew 安装:
```bash
brew install python@3.10
```

#### Linux (Ubuntu/Debian)
```bash
# 安装 Python 和 pip
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# 验证安装
python3 --version
pip3 --version
```

### 3. 安装项目依赖

#### 克隆或下载项目
```bash
cd /mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理
```

#### 创建 Python 虚拟环境
```bash
# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate
```

#### 安装 Python 依赖
```bash
pip install -r requirements.txt
```

如果遇到安装问题,尝试:
```bash
pip install --upgrade pip
pip install pandas openpyxl python-dateutil
```

#### 安装 Node 依赖
```bash
npm install
```

## 运行应用

### 开发模式
```bash
# 确保虚拟环境已激活
source venv/bin/activate  # Windows: venv\Scripts\activate

# 启动应用(会自动打开开发者工具)
npm run dev
```

### 生产模式
```bash
# 确保虚拟环境已激活
source venv/bin/activate

# 启动应用
npm start
```

## 打包应用

### 本地打包

#### 打包所有平台
```bash
npm run build:all
```

#### 打包特定平台
```bash
# Windows
npm run build:win

# macOS
npm run build:mac

# Linux
npm run build:linux
```

打包后的文件在 `dist/` 目录中。

### GitHub Actions 自动化构建

1. 将代码推送到 GitHub 仓库
2. 创建并推送版本标签:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions 会自动构建所有平台的安装包
4. 构建完成后,安装包会上传到 Release 页面

## 常见问题

### 1. 找不到 Node.js 或 Python

**问题**: `command not found: node` 或 `command not found: python`

**解决方案**:
- 确认已正确安装 Node.js 和 Python
- 将安装路径添加到系统环境变量 PATH
- Windows: 在"系统属性" > "环境变量"中添加
- macOS/Linux: 在 `~/.bashrc` 或 `~/.zshrc` 中添加 `export PATH="...:$PATH"`

### 2. pip 安装失败

**问题**: `ModuleNotFoundError: No module named 'pip'`

**解决方案**:
```bash
# Linux
sudo apt install python3-pip

# macOS
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py

# Windows
python -m ensurepip --upgrade
```

### 3. npm install 失败

**问题**: `npm ERR! code EACCES`

**解决方案**:
```bash
# 使用 --legacy-peer-deps
npm install --legacy-peer-deps

# 或清理缓存后重试
npm cache clean --force
npm install
```

### 4. Electron 启动失败

**问题**: Electron 窗口无法打开

**解决方案**:
- 确认虚拟环境已激活
- 检查 Python 依赖是否已安装:
  ```bash
  pip list | grep pandas
  ```
- 检查 Node 依赖是否已安装:
  ```bash
  ls node_modules
  ```

### 5. Python 虚拟环境问题

**问题**: 虚拟环境无法激活或找不到

**解决方案**:
```bash
# 重新创建虚拟环境
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 6. 文件路径问题

**问题**: WSL2 中访问 Windows 文件路径

**解决方案**:
- Windows 路径格式: `C:\Users\...`
- WSL2 中访问: `/mnt/c/Users/...`
- 应用中使用 `/mnt/c/Users/...` 格式

## 生产环境部署

### Windows 用户
1. 下载 `表格自动化清理工具 Setup x.x.x.exe`
2. 双击安装程序
3. 按照安装向导完成安装
4. 从开始菜单启动应用

### macOS 用户
1. 下载 `表格自动化清理工具-x.x.x.dmg`
2. 打开 DMG 文件
3. 将应用拖拽到 Applications 文件夹
4. 从 Launchpad 启动应用

### Linux 用户
1. 下载 `表格自动化清理工具-x.x.x.AppImage`
2. 添加执行权限:
   ```bash
   chmod +x 表格自动化清理工具-x.x.x.AppImage
   ```
3. 运行应用:
   ```bash
   ./表格自动化清理工具-x.x.x.AppImage
   ```

或使用 `.deb` 安装包:
```bash
sudo dpkg -i 表格自动化清理工具-x.x.x.deb
```

## 技术支持

如遇到其他问题,请:
1. 查看 [DEVELOPMENT.md](DEVELOPMENT.md) 开发文档
2. 检查 [GitHub Issues](https://github.com/你的用户名/table-cleaner/issues)
3. 提交 Issue 并附上详细的错误信息和系统环境

---

作者: zmx199299
开发工具: CodeBuddy-CN
开源协议: GPL-3.0
