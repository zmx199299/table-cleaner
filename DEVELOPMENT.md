# 开发文档

## 项目概述

表格自动化清理工具是一个基于 Electron + Python 开发的跨平台桌面应用,用于清洗和转换 Excel/CSV 数据文件。

## 技术栈

### 前端
- **Electron**: 跨平台桌面应用框架
- **HTML/CSS/JavaScript**: 用户界面
- **IPC**: 进程间通信

### 后端
- **Python 3.10+**: 数据处理逻辑
- **pandas**: 数据处理和分析
- **openpyxl**: Excel 文件读写
- **python-dateutil**: 日期时间处理

### 打包工具
- **electron-builder**: 跨平台打包
- **python-shell**: Electron 调用 Python

## 项目结构

```
表格自动化清理/
├── main.js                    # Electron 主进程
├── preload.js                 # 预加载脚本
├── package.json              # Node.js 配置
├── requirements.txt          # Python 依赖
├── README.md                 # 使用说明
├── DEVELOPMENT.md            # 开发文档
├── LICENSE                   # GPL v3 许可证
├── .gitignore               # Git 忽略文件
├── renderer/                # 渲染进程
│   ├── index.html           # 主页面
│   ├── style.css            # 样式文件
│   └── renderer.js          # 渲染进程逻辑
├── python/                  # Python 后端
│   ├── __init__.py          # 模块初始化
│   ├── file_parser.py       # 文件解析模块
│   ├── date_handler.py      # 日期处理模块
│   └── data_cleaner.py      # 数据清洗核心逻辑
└── assets/                  # 资源文件
    ├── icon.ico            # Windows 图标
    ├── icon.icns           # macOS 图标
    └── icon.png            # Linux 图标
```

## 核心模块说明

### 1. file_parser.py (文件解析模块)

**功能**:
- 读取 Excel/CSV 文件
- 获取 Excel 文件的 Sheet 列表
- 获取文件的列名
- 保存清洗后的数据

**主要函数**:
- `get_excel_sheets(file_path)`: 获取 Excel 文件的所有 Sheet 名称
- `get_columns(file_path, sheet, header_row)`: 获取文件列名
- `read_file(file_path, sheet, header_row)`: 读取文件为 DataFrame
- `save_file(data, file_path, format_type)`: 保存数据到文件

**命令行接口**:
```bash
python file_parser.py --get-sheets <file_path>
python file_parser.py --get-columns <file_path> <options_json>
python file_parser.py --read <file_path> <options_json>
python file_parser.py --save <data_json> <file_path> <format_type>
```

### 2. date_handler.py (日期处理模块)

**功能**:
- 识别多种日期格式 (yyyymmdd, yymdd, yymmd)
- 转换日期格式
- 自动补全缺失的时间部分

**主要函数**:
- `parse_date(date_str)`: 解析日期字符串
- `convert_date_format(date_str, target_format)`: 转换日期格式
- `convert_column_to_dates(column, target_format)`: 批量转换列

**支持的日期格式**:
- `yyyymmdd`: 20240315
- `yymdd`: 240315
- `yymmd`: 24/03/15, 24.03.15

**自动补全规则**:
- 目标格式为 `yyyymmddhhmmss` 时
  - 如果只有日期,自动补全为 `yyyymmdd000000`
  - 如果有时间部分,保留原始时间并格式化

### 3. data_cleaner.py (数据清洗核心)

**功能**:
- 应用列映射关系
- 处理日期列转换
- 处理金额列的正负号补全
- 生成清洗统计信息

**主要函数**:
- `apply_mapping(df, mappings)`: 应用列映射
- `process_date_column(df, date_column, date_format)`: 处理日期列
- `process_amount_columns(df, amount_column, direction_column)`: 处理金额列
- `clean_data(params)`: 执行完整的数据清洗流程

**清洗流程**:
1. 读取目标文件
2. 应用列映射关系
3. 转换日期格式
4. 补全金额正负号
5. 生成预览数据
6. 返回清洗结果

## Electron 通信机制

### IPC 通信

使用 Electron 的 `ipcMain` 和 `contextBridge` 实现:

**主进程 (main.js)**:
```javascript
ipcMain.handle('parse-file', async (event, filePath, options) => {
  return new Promise((resolve, reject) => {
    PythonShell.run('python/file_parser.py', {
      mode: 'text',
      pythonPath: path.join(__dirname, 'venv/bin/python'),
      args: [filePath, JSON.stringify(options)]
    }, (err, result) => {
      if (err) reject(err);
      else resolve(JSON.parse(result.join('')));
    });
  });
});
```

**预加载脚本 (preload.js)**:
```javascript
contextBridge.exposeInMainWorld('electronAPI', {
  parseFile: (filePath, options) => ipcRenderer.invoke('parse-file', filePath, options),
  cleanData: (data) => ipcRenderer.invoke('clean-data', data),
  saveFile: (data, filePath, format) => ipcRenderer.invoke('save-file', data, filePath, format)
});
```

**渲染进程 (renderer.js)**:
```javascript
const result = await window.electronAPI.parseFile(file.path, options);
```

## 开发环境搭建

### 1. 安装 Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2. 创建 Python 虚拟环境

```bash
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

### 3. 安装依赖

```bash
# 安装 Python 依赖
pip install -r requirements.txt

# 安装 Node 依赖
npm install
```

### 4. 运行应用

```bash
npm start
```

## 打包发布

### 本地打包

```bash
# 打包所有平台
npm run build:all

# 仅打包 Windows
npm run build:win

# 仅打包 Mac
npm run build:mac

# 仅打包 Linux
npm run build:linux
```

### GitHub Actions 自动化构建

配置 `.github/workflows/build.yml` 实现自动化构建和发布:

1. 提交代码推送到 GitHub
2. Actions 自动触发构建
3. 构建完成后自动创建 Release
4. 上传安装包到 Release

## 调试技巧

### 1. 开发模式

```bash
npm run dev
```

会自动打开开发者工具。

### 2. 查看日志

- 主进程日志: 在终端查看
- Python 后端日志: 在终端查看
- 渲染进程日志: 使用 DevTools Console

### 3. Python 调试

在 Python 代码中添加 `print()` 语句,输出会显示在终端。

## 常见问题

### 1. Python 环境问题

确保虚拟环境已激活:
```bash
source venv/bin/activate
```

### 2. 文件路径问题

Electron 中使用路径模块:
```javascript
const path = require('path');
path.join(__dirname, 'python/script.py')
```

### 3. IPC 通信失败

检查:
- contextBridge 是否正确配置
- 主进程是否正确注册了 ipcMain.handle
- 渲染进程是否正确调用了 electronAPI

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 版权信息

- **作者**: zmx199299
- **开发工具**: CodeBuddy-CN
- **开源协议**: GPL-3.0
