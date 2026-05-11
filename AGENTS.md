# AGENTS.md

本文件为AI代理（Claude、Copilot、Cursor等）提供项目指南，帮助理解和贡献NavicatMac项目。

## 项目概述

NavicatMac是一款macOS原生数据库管理工具，1:1复刻Navicat，优先支持MySQL，用于个人或团队内部使用。

## 技术栈

- **语言**: Swift 5.0+
- **UI框架**: SwiftUI
- **最低系统**: macOS 14.0 (Sonoma)
- **IDE**: Xcode 15.0+
- **架构**: arm64 (Apple Silicon) + x86_64 (Intel)

## 项目结构

```
navicat-mac/
├── NavicatMac.xcodeproj/         # Xcode项目文件
├── NavicatMac/                   # 主应用源码
│   ├── App/                      # 应用入口
│   │   └── NavicatMacApp.swift   # @main入口点
│   ├── Models/                   # 数据模型
│   │   └── Connection.swift      # 连接、数据库、表、字段等模型
│   ├── Services/                 # 服务层
│   │   └── ConnectionManager.swift  # 连接管理器和MySQL服务
│   ├── Views/                    # 视图层
│   │   ├── MainView.swift        # 主界面（侧边栏、内容区）
│   │   ├── Content/              # 内容视图
│   │   │   └── QueryEditorView.swift  # SQL编辑器和表设计器
│   │   └── Dialogs/              # 对话框
│   │       ├── ConnectionDialog.swift     # 连接配置
│   │       └── ImportExportWizard.swift   # 导入导出向导
│   └── NavicatMac.entitlements   # 应用权限配置
├── NavicatMacTests/              # 单元测试
│   └── NavicatMacTests.swift
├── docs/                         # 项目文档
│   ├── 可行性分析报告.md
│   ├── 需求规格说明书.md
│   ├── 技术架构设计.md
│   └── 发布指南.md
├── scripts/                      # 自动化脚本
│   ├── release.sh                # 版本发布脚本
│   └── create-release.sh         # GitHub Release创建脚本
├── Package.swift                 # Swift Package Manager配置（备用）
├── Makefile                      # 构建脚本
├── CHANGELOG.md                  # 变更日志
├── README.md                     # 项目说明
└── .gitignore                    # Git忽略规则
```

## 核心架构

### MVVM模式

```
View (SwiftUI) ←→ ViewModel (ObservableObject) ←→ Model
     ↓                      ↓                        ↓
  MainView          ConnectionManager          Connection
  QueryEditor       (Published属性)            Database
  ConnectionDialog                              Table
                                                Column
```

### 数据模型层次

```
Connection (连接)
  └── Database (数据库)
        ├── Table (表)
        │     ├── Column (字段)
        │     ├── Index (索引)
        │     └── ForeignKey (外键)
        ├── DatabaseView (视图)
        ├── StoredProcedure (存储过程)
        └── Function (函数)
```

### 关键类说明

| 类名 | 文件 | 职责 |
|------|------|------|
| `ConnectionManager` | Services/ConnectionManager.swift | 连接状态管理、数据库操作、查询执行 |
| `MySQLService` | Services/ConnectionManager.swift | MySQL连接和查询执行 |
| `QueryTab` | Models/Connection.swift | 查询标签页状态（ObservableObject） |
| `Connection` | Models/Connection.swift | 数据库连接配置模型 |

## 编码规范

### 命名规范

```swift
// 类名：PascalCase
class ConnectionManager { }

// 方法名：camelCase
func loadDatabases() { }

// 变量名：camelCase
var selectedDatabase: Database?

// 常量：camelCase（Swift风格）
let maxConnectionCount = 10

// 枚举：PascalCase，case camelCase
enum NavigationItem {
    case connection(Connection)
    case database(Database)
}
```

### 注释规范

```swift
// MARK: - 连接管理

/// 连接到数据库
/// - Parameter connection: 连接配置
/// - Throws: 连接错误
func connect(to connection: Connection) async throws {
    // 实现细节
}

// TODO: 实现连接池
// FIXME: 修复超时处理
// NOTE: 此方法需要在主线程调用
```

### SwiftUI规范

```swift
// 使用@EnvironmentObject注入共享状态
struct MainView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        // 视图内容
    }
}

// 使用@Published暴露可观察属性
class ConnectionManager: ObservableObject {
    @Published var connections: [Connection] = []
    @Published var activeConnection: Connection?
}

// MARK: - Tab枚举使用UUID而非关联值（避免Hashable问题）
enum Tab: Hashable, Identifiable {
    case query(UUID)
    case tableData(UUID)
    
    var id: String {
        switch self {
        case .query(let id): return "query_\(id)"
        case .tableData(let id): return "tableData_\(id)"
        }
    }
}
```

## 重要约定

### 1. 命名冲突避免

```swift
// ❌ 错误：View与SwiftUI.View冲突
struct View: Identifiable, Hashable { }

// ✅ 正确：使用DatabaseView避免冲突
struct DatabaseView: Identifiable, Hashable { }
```

### 2. Tab枚举设计

```swift
// ❌ 错误：使用关联值会导致Hashable问题
enum Tab: Hashable {
    case query(QueryTab)  // QueryTab是class，不满足Hashable
}

// ✅ 正确：使用UUID作为关联值
enum Tab: Hashable, Identifiable {
    case query(UUID)
    
    var id: String {
        switch self {
        case .query(let id): return "query_\(id)"
        }
    }
}
```

### 3. SwiftUI Switch语句

```swift
// ❌ 错误：switch不能直接修饰
GroupBox {
    switch result {
    case .success: ...
    case .failure: ...
    }
}
.padding()  // 编译错误

// ✅ 正确：用Group包裹
GroupBox {
    Group {
        switch result {
        case .success: ...
        case .failure: ...
        }
    }
    .padding()
}
```

### 4. UTType使用

```swift
// ❌ 错误：UTType.sql不存在
panel.allowedContentTypes = [.sql]

// ✅ 正确：使用.plainText替代
panel.allowedContentTypes = [.plainText]
```

### 5. ObservableObject要求

```swift
// ❌ 错误：struct不能用@ObservedObject
struct QueryTab: Identifiable { }
@ObservedObject var tab: QueryTab  // 编译错误

// ✅ 正确：使用class并 conform ObservableObject
class QueryTab: Identifiable, ObservableObject {
    @Published var query: String = ""
}
```

## 构建命令

```bash
# 构建调试版本
make build

# 构建发布版本
make release

# 运行应用
make run

# 打包dmg（arm64 + x86_64）
make package

# 运行测试
make test

# 清理构建
make clean

# 发布新版本
./scripts/release.sh -v 0.2.0 -m "版本描述"
```

## 测试规范

### 单元测试

```swift
import XCTest
@testable import NavicatMac

final class NavicatMacTests: XCTestCase {
    
    func testConnectionInitialization() {
        let connection = Connection(
            name: "测试连接",
            host: "localhost",
            port: 3306,
            username: "root",
            password: "password"
        )
        
        XCTAssertEqual(connection.name, "测试连接")
        XCTAssertEqual(connection.host, "localhost")
    }
}
```

### 测试文件位置

- 单元测试: `NavicatMacTests/`
- 测试命名: `test` + 功能描述 (如 `testConnectionInitialization`)

## Git规范

### 提交信息格式

```
<type>: <description>

[optional body]

[optional footer]
```

### 类型说明

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 添加PostgreSQL支持` |
| `fix` | 修复bug | `fix: 修复连接超时问题` |
| `docs` | 文档更新 | `docs: 更新README` |
| `chore` | 构建/工具 | `chore: 更新Makefile` |
| `refactor` | 重构 | `refactor: 优化查询执行` |
| `test` | 测试 | `test: 添加连接管理测试` |
| `release` | 版本发布 | `release: v0.2.0` |

### 分支策略

- `main`: 主分支，稳定版本
- `feature/*`: 功能分支
- `fix/*`: 修复分支
- `release/*`: 发布分支

## 版本发布流程

### 自动化发布

```bash
# 1. 确保所有更改已提交
git status

# 2. 运行发布脚本
./scripts/release.sh -v 0.2.0 -m "新增功能描述"

# 脚本自动执行：
# - 更新版本号
# - 更新CHANGELOG.md
# - 构建arm64和x86_64版本
# - 创建Git标签
# - 推送到远程仓库
# - 创建GitHub Release
# - 上传dmg文件
```

### 手动发布

```bash
# 1. 更新版本号和CHANGELOG.md
# 2. 构建dmg
make package

# 3. 创建标签并推送
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin main
git push origin v0.2.0

# 4. 在GitHub创建Release并上传dmg
```

## 常见问题解决

### 1. SwiftUI编译错误

**问题**: `inheritance from non-protocol type 'View'`
**原因**: 自定义`View`类型与SwiftUI.View冲突
**解决**: 重命名为`DatabaseView`或其他名称

### 2. Hashable协议不满足

**问题**: `type 'Tab' does not conform to protocol 'Hashable'`
**原因**: 枚举关联值不是Hashable
**解决**: 使用UUID作为关联值

### 3. switch修饰错误

**问题**: `instance member 'padding' cannot be used on type 'View'`
**原因**: SwiftUI不能直接修饰switch语句
**解决**: 用`Group`包裹switch

### 4. UTType不存在

**问题**: `type 'UTType' has no member 'sql'`
**原因**: UTType没有.sql
**解决**: 使用`.plainText`替代

### 5. ObservableObject要求

**问题**: `requires that 'QueryTab' conform to 'ObservableObject'`
**原因**: struct不能用@ObservedObject
**解决**: 改为class并 conform ObservableObject

## 待完成功能

- [ ] MySQL真实连接实现
- [ ] 语法高亮SQL编辑器
- [ ] 数据网格编辑功能
- [ ] 数据导入导出实现
- [ ] PostgreSQL支持
- [ ] SQLite支持
- [ ] 数据建模ER图
- [ ] 数据传输同步
- [ ] 暗黑模式支持
- [ ] 本地化支持

## 参考资源

- [SwiftUI文档](https://developer.apple.com/xcode/swiftui/)
- [Swift风格指南](https://www.swift.org/documentation/api-design-guidelines/)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Navicat官方文档](https://www.navicat.com/help/)

## 联系方式

- **GitHub**: https://github.com/yxgr-copilot/navicat-mac
- **Issues**: https://github.com/yxgr-copilot/navicat-mac/issues

## AGENTS.md维护指南

### 保持更新的重要性

AGENTS.md是AI代理理解项目的重要文件，需要随项目发展持续更新。过时的AGENTS.md可能导致：
- AI生成不符合项目规范的代码
- 遗漏重要的架构约定
- 重复已解决的问题

### 何时更新AGENTS.md

以下情况需要更新AGENTS.md：
1. **新增重要文件** - 新的模型、视图、服务文件
2. **架构变更** - 新的设计模式或架构调整
3. **编码规范变更** - 新的命名约定或代码风格
4. **发现新问题** - 编译陷阱或最佳实践
5. **功能完成** - 更新待办事项列表

### 更新方法

#### 自动检查

```bash
# 检查AGENTS.md是否需要更新
./scripts/maintain-agents.sh --check

# 显示项目统计信息
./scripts/maintain-agents.sh --stats

# 执行所有检查和更新
./scripts/maintain-agents.sh --all
```

#### 手动更新

1. 更新项目结构（如有新文件）
2. 更新编码规范（如有新约定）
3. 更新常见问题（如有新陷阱）
4. 更新待完成功能（如有完成功能）
5. 更新最后更新日期

### Git钩子

项目配置了post-commit钩子，会在以下情况提醒更新AGENTS.md：
- AGENTS.md超过7天未更新
- 新增Swift文件
- 新增模型或视图文件

### 更新检查清单

更新AGENTS.md时，请检查以下内容：

- [ ] 项目结构是否准确
- [ ] 核心架构是否完整
- [ ] 编码规范是否最新
- [ ] 常见问题是否覆盖
- [ ] 待办事项是否更新
- [ ] 最后更新日期是否正确

---

**最后更新**: 2026-05-11
**维护者**: yxgr-copilot