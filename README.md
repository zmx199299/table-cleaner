# 表格自动化清理工具

基于 Electron + Python 开发的数据清洗工具,支持 Excel 和 CSV 格式的数据清洗、格式转换和列映射。

## 功能特性

- 📊 支持导入多个 Excel/CSV 文件
- 🔄 灵活的列名映射配置
- 📅 智能日期格式识别和转换
- 💰 自动补全交易金额正负号
- 💾 支持导出 Excel 和 CSV 格式
- 🖥️ 跨平台支持 (Windows, Mac, Linux)

## 快速开始

### 安装依赖

```bash
# 创建 Python 虚拟环境
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装 Python 依赖
pip install -r requirements.txt

# 安装 Node 依赖
npm install
```

### 运行应用

```bash
npm start
```

### 构建应用

```bash
# 构建所有平台
npm run build:all

# 仅构建 Windows
npm run build:win

# 仅构建 Mac
npm run build:mac

# 仅构建 Linux
npm run build:linux
```

## 使用教程

### 步骤 1: 导入文件

1. 点击"选择目标文件"按钮,选择需要清洗的 Excel 或 CSV 文件
2. 如果是 Excel 文件,选择要清洗的 Sheet 页面
3. 指定表头行位置(默认第1行)

4. 点击"选择模板文件"按钮,选择包含目标列名的模板文件
5. 指定日期时间列及其格式(yyyymmdd 或 yyyymmddhhmmss)
6. 指定交易金额列和资金进出方向列

### 步骤 2: 配置映射

1. 在映射界面中,将目标文件的列名与模板文件的列名一一对应
2. 可以使用"添加映射"按钮手动添加映射关系
3. 使用"清空所有映射"按钮可以快速清空所有映射
4. 使用"删除"按钮可以删除指定的映射关系

### 步骤 3: 清洗数据

1. 在清洗预览中查看前5行数据
2. 查看清洗统计信息(日期转换、金额补全等)
3. 选择保存路径、文件名和文件格式
4. 点击"开始清洗并导出"按钮完成清洗

## 开发文档

### 项目结构

```
表格自动化清理/
├── main.js                 # Electron 主进程
├── preload.js              # 预加载脚本
├── package.json            # 项目配置
├── requirements.txt        # Python 依赖
├── renderer/               # 渲染进程
│   ├── index.html          # 主页面
│   ├── style.css           # 样式文件
│   └── renderer.js         # 渲染进程逻辑
├── python/                 # Python 后端
│   ├── __init__.py
│   ├── data_cleaner.py     # 数据清洗核心逻辑
│   ├── file_parser.py      # 文件解析模块
│   ├── date_handler.py     # 日期处理模块
│   └── column_mapper.py    # 列映射模块
└── assets/                 # 资源文件
    ├── icon.ico
    ├── icon.icns
    └── icon.png
```

### 技术栈

- **前端**: Electron + HTML + CSS + JavaScript
- **后端**: Python 3.10+
- **数据处理**: pandas, openpyxl
- **打包工具**: electron-builder

## 版权信息

- **作者**: zmx199299
- **开发工具**: CodeBuddy-CN
- **开源协议**: GPL-3.0

## 许可证

本项目采用 GPL-3.0 协议开源。详见 [LICENSE](LICENSE) 文件。
