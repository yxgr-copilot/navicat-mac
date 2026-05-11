import SwiftUI

// MARK: - 导航项枚举
enum NavigationItem: Hashable {
    case connection(Connection)
    case database(Database)
    case table(Table)
    case view(DatabaseView)
    case procedure(StoredProcedure)
    case function(Function)
}

// MARK: - 内容项枚举
enum ContentItem: Hashable {
    case table(Table)
    case view(DatabaseView)
    case procedure(StoredProcedure)
    case function(Function)
}

// MARK: - Tab枚举
enum Tab: Hashable, Identifiable {
    case query(UUID)
    case tableData(UUID)
    case tableDesign(UUID)
    
    var id: String {
        switch self {
        case .query(let id): return "query_\(id)"
        case .tableData(let id): return "tableData_\(id)"
        case .tableDesign(let id): return "tableDesign_\(id)"
        }
    }
}

// MARK: - 主视图
struct MainView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var selectedTab: Tab = .query(UUID())
    @State private var sidebarWidth: CGFloat = 220
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            toolbarView
            
            // 主内容区
            HStack(spacing: 0) {
                // 左侧边栏
                sidebarView
                    .frame(width: sidebarWidth)
                
                // 分隔线
                Divider()
                
                // 右侧内容区
                contentArea
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
        .background(Color(.controlBackgroundColor))
    }
    
    // MARK: - 工具栏
    private var toolbarView: some View {
        HStack(spacing: 0) {
            // 左侧功能按钮组
            HStack(spacing: 2) {
                ToolbarButton(icon: "plus.circle", title: "连接") {
                    connectionManager.showNewConnectionDialog = true
                }
                
                ToolbarButton(icon: "doc.text", title: "新建查询") {
                    connectionManager.createNewQuery()
                }
                
                ToolbarButton(icon: "tablecells", title: "表") {
                    // 切换到表视图
                }
                
                ToolbarButton(icon: "eye", title: "视图") {
                    // 切换到视图
                }
                
                ToolbarButton(icon: "function", title: "函数") {
                    // 切换到函数
                }
                
                ToolbarButton(icon: "person", title: "用户") {
                    // 切换到用户
                }
                
                ToolbarButton(icon: "ellipsis.circle", title: "其它") {
                    // 其它功能
                }
                
                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 6)
                
                ToolbarButton(icon: "magnifyingglass", title: "查询") {
                    // 查询功能
                }
                
                ToolbarButton(icon: "arrow.clockwise", title: "备份") {
                    // 备份功能
                }
                
                ToolbarButton(icon: "play.circle", title: "自动运行") {
                    // 自动运行
                }
                
                ToolbarButton(icon: "cube", title: "模型") {
                    // 数据模型
                }
                
                ToolbarButton(icon: "chart.bar", title: "BI") {
                    // BI分析
                }
            }
            .padding(.horizontal, 10)
            
            Spacer()
            
            // 右侧操作按钮组
            HStack(spacing: 8) {
                // 执行按钮
                Button(action: {
                    connectionManager.executeCurrentQuery()
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .disabled(!connectionManager.canExecuteQuery)
                .help("执行查询")
                
                // 停止按钮
                Button(action: {
                    connectionManager.stopCurrentQuery()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .disabled(!connectionManager.isExecuting)
                .help("停止查询")
                
                Divider()
                    .frame(height: 20)
                
                // 刷新按钮
                Button(action: {
                    connectionManager.refreshCurrentView()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("刷新")
                
                // 导入导出按钮
                Menu {
                    Button("导入向导") {
                        connectionManager.showImportWizard = true
                    }
                    Button("导出向导") {
                        connectionManager.showExportWizard = true
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14))
                }
                .menuStyle(.borderlessButton)
                .frame(width: 20)
                .help("导入/导出")
                
                // 搜索按钮
                Button(action: {
                    connectionManager.showSearch = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("搜索")
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 44)
        .background(Color(.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
    
    // MARK: - 侧边栏
    private var sidebarView: some View {
        VStack(spacing: 0) {
            // 侧边栏标题
            HStack {
                Text("我的连接")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    connectionManager.showNewConnectionDialog = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // 连接树
            List(selection: $connectionManager.selectedItem) {
                ForEach(connectionManager.connections) { connection in
                    ConnectionTreeView(connection: connection)
                        .tag(NavigationItem.connection(connection))
                }
            }
            .listStyle(.sidebar)
            
            // 底部搜索框
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                TextField("搜索连接...", text: $connectionManager.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.textBackgroundColor).opacity(0.5))
            .cornerRadius(6)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.controlBackgroundColor))
    }
    
    // MARK: - 内容区
    private var contentArea: some View {
        VStack(spacing: 0) {
            // 标签页栏
            tabBar
            
            // 内容视图
            TabView(selection: $selectedTab) {
                // 查询标签页
                ForEach(connectionManager.queryTabs) { tab in
                    QueryEditorView(tab: tab)
                        .tabItem {
                            Label(tab.title, systemImage: "doc.text")
                        }
                        .tag(Tab.query(tab.id))
                }
                
                // 表数据标签页
                if let table = connectionManager.selectedTable {
                    TableDataView(table: table)
                        .tabItem {
                            Label(table.name, systemImage: "tablecells")
                        }
                        .tag(Tab.tableData(table.id))
                }
                
                // 表设计标签页
                if let table = connectionManager.selectedTableForDesign {
                    TableDesignerView(table: table)
                        .tabItem {
                            Label("设计: \(table.name)", systemImage: "pencil")
                        }
                        .tag(Tab.tableDesign(table.id))
                }
            }
            .tabViewStyle(.automatic)
        }
    }
    
    // MARK: - 标签页栏
    private var tabBar: some View {
        HStack(spacing: 0) {
            // 标签页列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(connectionManager.queryTabs) { tab in
                        TabItem(
                            title: tab.title,
                            icon: "doc.text",
                            isSelected: selectedTab == .query(tab.id),
                            onClose: {
                                // 关闭标签页
                            }
                        ) {
                            selectedTab = .query(tab.id)
                        }
                    }
                    
                    if let table = connectionManager.selectedTable {
                        TabItem(
                            title: table.name,
                            icon: "tablecells",
                            isSelected: selectedTab == .tableData(table.id),
                            onClose: {
                                connectionManager.selectedTable = nil
                            }
                        ) {
                            selectedTab = .tableData(table.id)
                        }
                    }
                    
                    if let table = connectionManager.selectedTableForDesign {
                        TabItem(
                            title: "设计: \(table.name)",
                            icon: "pencil",
                            isSelected: selectedTab == .tableDesign(table.id),
                            onClose: {
                                connectionManager.selectedTableForDesign = nil
                            }
                        ) {
                            selectedTab = .tableDesign(table.id)
                        }
                    }
                }
            }
            
            // 新建标签页按钮
            Button(action: {
                connectionManager.createNewQuery()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("新建查询")
        }
        .frame(height: 32)
        .background(Color(.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
}

// MARK: - 工具栏按钮
struct ToolbarButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 11))
            }
            .frame(width: 56, height: 40)
            .foregroundColor(.primary)
            .background(Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 标签页项
struct TabItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onClose: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(isSelected ? .accentColor : .secondary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .primary : .secondary)
                .lineLimit(1)
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(isSelected ? 1 : 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(isSelected ? Color(.controlBackgroundColor) : Color.clear)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(isSelected ? Color.accentColor : Color.clear),
            alignment: .bottom
        )
        .onTapGesture(perform: onTap)
    }
}

// MARK: - 连接树视图
struct ConnectionTreeView: View {
    let connection: Connection
    
    var body: some View {
        DisclosureGroup {
            // 数据库列表
            ForEach(connection.databases) { database in
                DatabaseTreeView(database: database)
            }
        } label: {
            HStack(spacing: 6) {
                // 连接状态图标
                Image(systemName: connection.isConnected ? "server.rack" : "server.rack")
                    .font(.system(size: 13))
                    .foregroundColor(connection.isConnected ? .green : .gray)
                
                // 连接颜色标记
                Circle()
                    .fill(connection.connectionColor)
                    .frame(width: 6, height: 6)
                
                // 连接名称
                VStack(alignment: .leading, spacing: 2) {
                    Text(connection.name)
                        .font(.system(size: 12))
                        .lineLimit(1)
                    
                    Text("\(connection.username)@\(connection.host)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

// MARK: - 数据库树视图
struct DatabaseTreeView: View {
    let database: Database
    
    var body: some View {
        DisclosureGroup {
            // 表
            ForEach(database.tables) { table in
                Label {
                    Text(table.name)
                        .font(.system(size: 12))
                } icon: {
                    Image(systemName: "tablecells")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
            }
            
            // 视图
            ForEach(database.views) { view in
                Label {
                    Text(view.name)
                        .font(.system(size: 12))
                } icon: {
                    Image(systemName: "eye")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
            
            // 存储过程
            ForEach(database.procedures) { procedure in
                Label {
                    Text(procedure.name)
                        .font(.system(size: 12))
                } icon: {
                    Image(systemName: "function")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
            }
        } label: {
            Label {
                Text(database.name)
                    .font(.system(size: 12))
            } icon: {
                Image(systemName: "database")
                    .font(.system(size: 13))
                    .foregroundColor(.purple)
            }
        }
    }
}

// MARK: - 预览
#Preview {
    MainView()
        .environmentObject(ConnectionManager())
}