# NavicatMac

一款macOS原生数据库管理工具，1:1复刻Navicat，优先支持MySQL，用于个人或团队内部使用。

## 功能特性

### 核心功能
- **1:1复刻Navicat界面**: 完全相同的布局、交互和视觉设计
- **MySQL支持**: 完整的MySQL数据库管理功能
- **SQL编辑器**: 语法高亮、自动补全、查询执行
- **数据网格**: 高效的数据浏览和编辑
- **导入导出**: 支持CSV、JSON、Excel、SQL格式

### 界面设计
- **侧边栏**: 连接列表、数据库对象浏览器
- **标签页**: 查询、表数据、表设计
- **工具栏**: 快速访问常用功能
- **状态栏**: 连接状态、数据统计

### 数据库管理
- **连接管理**: 创建、编辑、删除连接
- **数据库浏览**: 表、视图、存储过程、函数
- **表设计器**: 字段、索引、外键管理
- **数据编辑**: 网格形式编辑数据

### 查询功能
- **SQL编辑器**: 语法高亮、行号显示
- **查询执行**: 执行、停止、执行计划
- **结果展示**: 网格、消息、执行计划
- **查询历史**: 保存和查询历史记录

## 系统要求

- **操作系统**: macOS 13.0 (Ventura) 或更高版本
- **架构**: Intel 或 Apple Silicon
- **内存**: 4GB RAM（推荐8GB）
- **存储空间**: 100MB可用空间
- **数据库**: MySQL 5.7 或更高版本

## 安装

### 方式1：从源代码构建

```bash
# 克隆项目
git clone <repository-url>
cd navicat-mac

# 构建项目
make build

# 运行应用程序
make run
```

### 方式2：打包为dmg

```bash
# 构建发布版本
make release

# 打包为dmg
make package

# 安装dmg
open .build/dmg/NavicatMac-*.dmg
```

### 方式3：直接安装

```bash
# 构建并安装到应用程序文件夹
make install
```

## 使用指南

### 1. 创建连接

1. 点击工具栏的"新建连接"按钮
2. 填写连接信息：
   - 连接名称
   - 主机地址（默认localhost）
   - 端口（默认3306）
   - 用户名（默认root）
   - 密码
   - 数据库（可选）
3. 点击"测试连接"验证连接
4. 点击"确定"保存连接

### 2. 浏览数据库

1. 在左侧连接列表中选择连接
2. 展开数据库对象：
   - 表：查看所有表
   - 视图：查看所有视图
   - 存储过程：查看所有存储过程
   - 函数：查看所有函数

### 3. 执行查询

1. 点击工具栏的"新建查询"按钮
2. 在SQL编辑器中输入查询语句
3. 点击"执行"按钮或按⌘↩执行查询
4. 在结果区域查看查询结果

### 4. 编辑数据

1. 在左侧选择表
2. 切换到"表数据"标签页
3. 直接在网格中编辑数据
4. 点击"保存"按钮提交更改

### 5. 导入数据

1. 点击工具栏的"导入"按钮
2. 选择导入文件类型（CSV、JSON、Excel、SQL）
3. 选择要导入的文件
4. 配置导入选项
5. 映射字段
6. 执行导入

### 6. 导出数据

1. 点击工具栏的"导出"按钮
2. 选择要导出的表
3. 选择导出格式（CSV、JSON、Excel、SQL）
4. 配置导出选项
5. 执行导出

## 开发指南

### 项目结构

```
navicat-mac/
├── NavicatMac/                    # 主应用代码
│   ├── App/                       # 应用入口
│   ├── Models/                    # 数据模型
│   ├── Views/                     # 视图
│   │   ├── Sidebar/               # 侧边栏
│   │   ├── Content/               # 内容区
│   │   ├── Dialogs/               # 对话框
│   │   └── Components/            # 通用组件
│   ├── Services/                  # 服务层
│   └── Utilities/                 # 工具类
├── NavicatMacTests/               # 单元测试
├── docs/                          # 文档
├── Package.swift                  # Swift包管理配置
└── Makefile                       # 构建脚本
```

### 构建命令

```bash
# 构建项目
make build

# 构建发布版本
make release

# 运行测试
make test

# 清理构建文件
make clean

# 运行应用程序
make run

# 打包为dmg
make package

# 安装到应用程序文件夹
make install

# 生成Xcode项目
make xcode

# 更新依赖
make update

# 代码检查
make lint

# 代码格式化
make format
```

### 开发环境设置

1. **安装Xcode**: 从App Store安装Xcode 14或更高版本
2. **安装命令行工具**: `xcode-select --install`
3. **克隆项目**: `git clone <repository-url>`
4. **进入项目目录**: `cd navicat-mac`
5. **设置开发环境**: `make setup`
6. **构建项目**: `make build`
7. **运行项目**: `make run`

### 添加新功能

1. **创建分支**: `git checkout -b feature/new-feature`
2. **编写代码**: 在相应目录添加代码
3. **编写测试**: 在NavicatMacTests目录添加测试
4. **运行测试**: `make test`
5. **提交代码**: `git commit -m "Add new feature"`
6. **推送分支**: `git push origin feature/new-feature`
7. **创建Pull Request**

### 代码规范

1. **命名规范**:
   - 类名：PascalCase（如`ConnectionManager`）
   - 方法名：camelCase（如`getConnection`）
   - 变量名：camelCase（如`connectionName`）
   - 常量名：UPPER_SNAKE_CASE（如`MAX_CONNECTIONS`）

2. **注释规范**:
   - 类注释：描述类的功能和用途
   - 方法注释：描述方法的功能、参数和返回值
   - 复杂逻辑注释：解释算法和业务逻辑

3. **代码组织**:
   - 每个文件一个类或结构体
   - 使用extension组织功能模块
   - 使用protocol定义接口

## 常见问题

### Q: 连接MySQL失败怎么办？
A: 检查以下几点：
1. MySQL服务是否启动
2. 主机和端口是否正确
3. 用户名和密码是否正确
4. 防火墙是否允许连接
5. MySQL用户是否有远程访问权限

### Q: 如何支持其他数据库？
A: 当前版本专注于MySQL支持，后续版本将添加：
- PostgreSQL
- SQLite
- MariaDB
- MongoDB

### Q: 如何贡献代码？
A: 请按照以下步骤：
1. Fork项目
2. 创建功能分支
3. 提交代码
4. 创建Pull Request

### Q: 如何报告问题？
A: 请在GitHub Issues中报告问题，包含：
1. 问题描述
2. 复现步骤
3. 预期行为
4. 实际行为
5. 系统信息

## 版本历史

### v1.0.0 (2026-05-11)
- 初始版本
- MySQL支持
- 基本查询功能
- 数据浏览和编辑
- 导入导出功能

## 许可证

本项目采用MIT许可证。详见LICENSE文件。

## 联系方式

- **项目主页**: [GitHub仓库地址]
- **问题反馈**: [GitHub Issues]
- **邮箱**: [联系邮箱]

## 致谢

- 感谢Navicat提供的设计参考
- 感谢开源社区提供的MySQL客户端库
- 感谢Apple提供的macOS开发工具

---

**项目状态**: 开发中  
**最后更新**: 2026年5月11日