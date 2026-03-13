#!/bin/bash

# 表格自动化清理工具 - 推送到 GitHub 脚本

echo "====================================="
echo "表格自动化清理工具 - GitHub 上传脚本"
echo "====================================="
echo ""

# 提示用户输入 GitHub 用户名
read -p "请输入你的 GitHub 用户名: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "错误: 用户名不能为空"
    exit 1
fi

# 项目名称
REPO_NAME="table-cleaner"

# 检查远程仓库是否已存在
if git remote get-url origin &>/dev/null; then
    echo "检测到已存在的远程仓库:"
    git remote -v
    echo ""
    read -p "是否要更新远程仓库URL? (y/n): " UPDATE_REMOTE
    if [ "$UPDATE_REMOTE" = "y" ] || [ "$UPDATE_REMOTE" = "Y" ]; then
        git remote set-url origin https://github.com/$USERNAME/$REPO_NAME.git
        echo "远程仓库URL已更新"
    fi
else
    # 添加远程仓库
    git remote add origin https://github.com/$USERNAME/$REPO_NAME.git
    echo "已添加远程仓库"
fi

echo ""
echo "远程仓库信息:"
git remote -v
echo ""

# 推送代码
echo "正在推送代码到 GitHub..."
echo ""
echo "====================================="
echo "请注意:"
echo "1. 推送时需要输入 GitHub 用户名和 Personal Access Token"
echo "2. 如需生成 Token,访问: https://github.com/settings/tokens"
echo "3. Token 需要 'repo' 权限"
echo "====================================="
echo ""

git push -u origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 代码推送成功!"
    echo ""

    # 询问是否创建版本标签
    read -p "是否要创建版本标签 v1.0.0 并触发自动构建? (y/n): " CREATE_TAG

    if [ "$CREATE_TAG" = "y" ] || [ "$CREATE_TAG" = "Y" ]; then
        git tag v1.0.0
        git push origin v1.0.0

        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ 版本标签推送成功!"
            echo ""
            echo "GitHub Actions 将自动开始构建:"
            echo "- Windows: .exe 安装包"
            echo "- macOS: .dmg 安装包"
            echo "- Linux: .AppImage 和 .deb 安装包"
            echo ""
            echo "构建进度查看: https://github.com/$USERNAME/$REPO_NAME/actions"
            echo "下载地址: https://github.com/$USERNAME/$REPO_NAME/releases"
        fi
    fi
else
    echo ""
    echo "❌ 推送失败,请检查:"
    echo "1. GitHub 用户名是否正确"
    echo "2. 是否已在 GitHub 创建仓库"
    echo "3. Personal Access Token 是否有效"
    echo ""
    echo "详细信息请查看: GITHUB_UPLOAD_GUIDE.md"
    exit 1
fi
