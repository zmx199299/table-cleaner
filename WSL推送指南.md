# WSL 终端推送指南

## 问题解决

由于 WSL 终端无法交互式输入 GitHub 凭证,需要先配置凭证。

## 方式 1: 使用凭证存储(推荐)

### 步骤 1: 手动创建凭证文件

创建 `.git-credentials` 文件:

```bash
cd ~
cat > .git-credentials << 'EOF'
https://zmx199299:YOUR_TOKEN@github.com
EOF
chmod 600 .git-credentials
```

⚠️ **重要**: 将 `YOUR_TOKEN` 替换为你的 Personal Access Token

### 步骤 2: 配置 Git 使用凭证文件

```bash
git config --global credential.helper store
```

### 步骤 3: 推送代码

```bash
cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'
git push origin master
```

### 步骤 4: 创建并推送标签

```bash
git tag v1.0.0
git push origin v1.0.0
```

---

## 方式 2: 使用 GitHub CLI (最推荐)

### 步骤 1: 安装 GitHub CLI

```bash
# Ubuntu/Debian
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh
```

### 步骤 2: 登录 GitHub

```bash
gh auth login
```

按照提示操作:
1. 选择 `GitHub.com`
2. 选择 `HTTPS`
3. 选择 `Login with a web browser`

这会打开浏览器,你只需在网页中授权即可。

### 步骤 3: 推送代码

登录成功后,直接执行:

```bash
cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'
git push origin master
git tag v1.0.0
git push origin v1.0.0
```

---

## 方式 3: 使用 SSH 密钥(无需输入密码)

### 步骤 1: 生成 SSH 密钥

```bash
ssh-keygen -t ed25519 -C "zmx199299"
```

按回车使用默认路径,可以不设置密码。

### 步骤 2: 复制公钥

```bash
cat ~/.ssh/id_ed25519.pub
```

### 步骤 3: 添加到 GitHub

1. 访问: https://github.com/settings/keys
2. 点击 "New SSH key"
3. Title: WSL
4. Key: 粘贴刚才复制的公钥
5. 点击 "Add SSH key"

### 步骤 4: 修改远程仓库 URL 为 SSH

```bash
cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'
git remote set-url origin git@github.com:zmx199299/table-cleaner.git
```

### 步骤 5: 推送代码

```bash
git push origin master
git tag v1.0.0
git push origin v1.0.0
```

---

## 推荐操作步骤

我推荐使用 **方式 1(凭证存储)**,因为最简单:

```bash
# 1. 创建凭证文件(替换 YOUR_TOKEN)
cd ~
cat > .git-credentials << 'EOF'
https://zmx199299:YOUR_TOKEN@github.com
EOF
chmod 600 .git-credentials

# 2. 配置 Git
git config --global credential.helper store

# 3. 推送代码
cd '/mnt/c/Users/zmx19/OneDrive/私人/codelearn/表格自动化清理'
git push origin master

# 4. 创建并推送标签
git tag v1.0.0
git push origin v1.0.0
```

---

## Personal Access Token 获取

如果还没有 Token:

1. 访问: https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 填写:
   - Note: table-cleaner
   - Expiration: 90 days 或 No expiration
   - Select scopes: ✅ repo
4. 点击 "Generate token"
5. 复制 Token (只显示一次!)

---

## 验证推送成功

推送完成后访问:
- https://github.com/zmx199299/table-cleaner
- https://github.com/zmx199299/table-cleaner/actions (查看构建)
- https://github.com/zmx199299/table-cleaner/releases (下载安装包)

---

作者: zmx199299
开发工具: CodeBuddy-CN
