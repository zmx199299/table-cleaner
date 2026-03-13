# GitHub 上传指南

## 步骤 1: 在 GitHub 创建新仓库

1. 访问 [GitHub](https://github.com/) 并登录你的账号
2. 点击右上角的 `+` 号,选择 `New repository`
3. 填写仓库信息:
   - **Repository name**: `table-cleaner` (或其他你喜欢的名称)
   - **Description**: `表格自动化清理工具 - 基于 Electron + Python 的数据清洗应用`
   - **Public/Private**: 选择 `Public` 或 `Private`
   - ✅ **Add a README file**: **不要勾选** (我们已经有 README.md 了)
   - ✅ **Add .gitignore**: **不要勾选** (我们已经有 .gitignore 了)
   - ✅ **Choose a license**: 可以选择 GPL-3.0 或不选择 (我们已经有 LICENSE 了)
4. 点击 `Create repository` 按钮

## 步骤 2: 连接本地仓库到 GitHub

### Windows 命令提示符 (cmd)

```cmd
cd C:\Users\zmx19\OneDrive\私人\codelearn\表格自动化清理

# 添加远程仓库 (替换 YOUR_USERNAME 为你的 GitHub 用户名)
git remote add origin https://github.com/YOUR_USERNAME/table-cleaner.git

# 验证远程仓库
git remote -v

# 推送代码到 GitHub
git push -u origin master
```

### WSL2 Linux 终端

```bash
cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'

# 添加远程仓库 (替换 YOUR_USERNAME 为你的 GitHub 用户名)
git remote add origin https://github.com/YOUR_USERNAME/table-cleaner.git

# 验证远程仓库
git remote -v

# 推送代码到 GitHub
git push -u origin master
```

## 步骤 3: 输入 GitHub 凭证

当你执行 `git push` 时,会提示你输入 GitHub 凭证:

### 方式 1: 用户名和密码 (已废弃)

```
Username: YOUR_GITHUB_USERNAME
Password: YOUR_PERSONAL_ACCESS_TOKEN
```

**注意**: GitHub 已经不再支持密码登录,你需要使用 Personal Access Token。

### 方式 2: 使用 Personal Access Token (推荐)

1. 生成 Personal Access Token:
   - 访问 https://github.com/settings/tokens
   - 点击 `Generate new token` → `Generate new token (classic)`
   - 填写:
     - **Note**: `table-cleaner`
     - **Expiration**: 选择过期时间 (如 90 days 或 No expiration)
     - **Select scopes**: 勾选 `repo` (完整的仓库访问权限)
   - 点击 `Generate token`
   - **复制生成的 token** (只显示一次,请妥善保存)

2. 使用 Token 推送:
   ```
   Username: YOUR_GITHUB_USERNAME
   Password: YOUR_PASTE_TOKEN_HERE
   ```

### 方式 3: 使用 GitHub CLI (最推荐)

如果你经常使用 GitHub,建议安装 GitHub CLI:

```bash
# Windows (使用 winget)
winget install --id GitHub.cli

# Linux
sudo apt install gh
```

安装后认证:

```bash
gh auth login
```

按照提示选择:
1. GitHub.com
2. HTTPS
3. Login with a web browser

然后就可以直接推送,无需输入凭证:

```bash
git push -u origin master
```

## 步骤 4: 验证上传成功

推送完成后:

1. 刷新 GitHub 仓库页面
2. 你应该能看到所有文件都已上传
3. 查看 README.md 的显示效果

## 步骤 5: 创建版本标签并触发自动构建

```bash
# 创建版本标签
git tag v1.0.0

# 推送标签到 GitHub
git push origin v1.0.0
```

推送标签后,GitHub Actions 会自动:
1. 在 Windows、macOS、Linux 三个平台构建应用
2. 生成安装包:
   - Windows: .exe 文件
   - macOS: .dmg 文件
   - Linux: .AppImage 和 .deb 文件
3. 自动创建 Release
4. 上传所有安装包到 Release 页面

## 常见问题

### 问题 1: 推送时提示 "Permission denied"

**原因**: 凭证错误或无权限

**解决**:
- 确认使用的是你的 GitHub 用户名
- 如果使用密码,改为使用 Personal Access Token
- 检查 Token 是否有 `repo` 权限

### 问题 2: 推送时提示 "remote: Repository not found"

**原因**: 仓库 URL 错误或仓库不存在

**解决**:
- 确认仓库名称拼写正确
- 确认已成功创建 GitHub 仓库
- 检查远程 URL: `git remote -v`

### 问题 3: "Updates were rejected"

**原因**: 远程仓库有本地没有的文件

**解决**:
```bash
# 强制推送 (会覆盖远程仓库)
git push -u origin master --force

# 或者先拉取再推送
git pull origin master --allow-unrelated-histories
git push -u origin master
```

### 问题 4: Personal Access Token 过期

**原因**: Token 有有效期限制

**解决**:
- 重新生成 Token
- 更新 git 凭证:
  ```bash
  git config --global credential.helper store
  git push
  # 输入新的 Token
  ```

## 完整操作示例

```bash
# 1. 进入项目目录
cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'

# 2. 添加远程仓库 (替换为你的用户名)
git remote add origin https://github.com/zmx199299/table-cleaner.git

# 3. 推送代码
git push -u origin master

# 4. 创建并推送版本标签
git tag v1.0.0
git push origin v1.0.0

# 5. 等待 GitHub Actions 自动构建完成
# 访问 https://github.com/zmx199299/table-cleaner/actions 查看构建进度

# 6. 构建完成后,在 Release 页面下载安装包
# 访问 https://github.com/zmx199299/table-cleaner/releases
```

## 后续维护

### 更新代码

```bash
# 修改文件后
git add .
git commit -m "描述你的更改"
git push origin master

# 创建新版本
git tag v1.0.1
git push origin v1.0.1
```

### 从其他地方同步代码

```bash
# 克隆仓库到其他地方
git clone https://github.com/YOUR_USERNAME/table-cleaner.git

# 或者拉取最新更改
git pull origin master
```

---

**作者**: zmx199299
**开发工具**: CodeBuddy-CN
**日期**: 2026-03-13
