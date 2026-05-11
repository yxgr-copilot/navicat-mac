# Changelog

本文件记录NavicatMac项目的所有重要变更。

格式基于[Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循[语义化版本控制](https://semver.org/lang/zh-CN/)。

## [未发布]

### 新增
- 无

### 变更
- 无

### 修复
- 无

## [0.2.5] - 2026-05-12

### 修复
- 标题栏现在显示NavicatMac而不是查询1
- 版本号更新为0.2.4 (24)
- 使用WindowGroup("NavicatMac")设置窗口标题

## [0.2.4] - 2026-05-11

### 变更
- 移除自定义标题栏
- 使用系统原生标题栏（红绿灯栏）
- NavicatMac名称显示在红绿灯右侧
- 标题栏高度与Navicat Premium一致

## [0.2.3] - 2026-05-11

### 变更
- 添加自定义标题栏（28px高度）
- 居中显示NavicatMac名称
- 隐藏默认标题栏使用windowStyle(.hiddenTitleBar)
- 保持红绿灯按钮在左上角

## [0.2.2] - 2026-05-11

### 变更
- 工具栏高度调整为44px（与Navicat Premium一致）
- 工具栏按钮大小调整为56x40px
- 图标大小调整为18px
- 文字大小调整为11px
- 优化整体布局比例

## [0.2.1] - 2026-05-11

### 变更
- 降低工具栏高度从44px到28px
- 更新工具栏按钮列表：连接、新建查询、表、视图、函数、用户、其它、查询、备份、自动运行、模型、BI
- 优化按钮样式和间距
- 使整体布局更紧凑

## [0.2.0] - 2026-05-11

### 新增
- 添加ToolbarButton工具栏按钮组件
- 添加TabItem标签页组件
- 添加ConnectionTreeView连接树视图
- 添加DatabaseTreeView数据库树视图
- 添加NavigationItem和ContentItem枚举

### 变更
- 重构MainView参考Navicat Premium UI设计
- 采用三段式布局：工具栏、侧边栏、内容区
- 添加水平功能工具栏（连接、查询、表、视图等）
- 优化侧边栏设计（标题、连接树、搜索框）
- 改进标签页栏设计
- 保持浅色主题配色方案

### 修复
- 修复Tab枚举Hashable协议问题
- 修复NavigationItem和ContentItem作用域问题

## [0.1.2] - 2026-05-11

### 新增
- 添加版本发布指南文档（docs/发布指南.md）
- 详细说明自动化和手动发布流程
- 包含GitHub Token配置说明
- 包含版本号规范和变更日志规范

## [0.1.1] - 2026-05-11

### 新增
- 添加scripts/create-release.sh脚本用于创建GitHub Release
- 添加scripts/release.sh脚本用于自动化版本发布流程
- 添加prepare-commit-msg Git钩子自动更新CHANGELOG.md

### 变更
- 更新CHANGELOG.md添加v0.1.0版本信息

## [0.1.0] - 2026-05-11

### 新增
- 项目初始化
- 完整的项目文档（可行性分析、需求规格、技术架构）
- Xcode项目配置和构建系统
- 核心数据模型（连接、数据库、表、字段、索引、外键）
- 连接管理器和MySQL服务层
- 主界面框架（侧边栏、内容区、详情区）
- SQL查询编辑器（语法高亮、行号显示）
- 连接对话框（MySQL连接配置）
- 导入导出向导（CSV、JSON、Excel、SQL）
- 表设计器（字段、索引、外键管理）
- 单元测试框架
- Makefile构建脚本
- dmg打包支持
- .gitignore配置

### 技术栈
- Swift 5.0+
- SwiftUI
- macOS 14.0+
- Xcode 15.0+

---

## 版本说明

- **主版本号**：不兼容的API修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

## 变更类型

- **新增**：新功能
- **变更**：对现有功能的变更
- **弃用**：不建议使用的功能
- **移除**：移除的功能
- **修复**：bug修复
- **安全**：安全相关的变更