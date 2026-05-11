import SwiftUI

struct MainView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var selectedTab: Tab = .query
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    enum Tab: String, CaseIterable {
        case query = "查询"
        case table = "表"
        case view = "视图"
        case procedure = "存储过程"
        case function = "函数"
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // 侧边栏
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 350)
        } content: {
            // 内容列表
            ContentListView()
                .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
        } detail: {
            // 详情视图
            DetailView()
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // 左侧工具栏按钮
                Button(action: {
                    connectionManager.showNewConnectionDialog = true
                }) {
                    Label("新建连接", systemImage: "plus.circle")
                }
                .help("新建数据库连接")
                
                Button(action: {
                    connectionManager.createNewQuery()
                }) {
                    Label("新建查询", systemImage: "doc.text")
                }
                .help("新建SQL查询")
            }
            
            ToolbarItemGroup(placement: .principal) {
                // 中间工具栏按钮
                Picker("标签页", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
            }
            
            ToolbarItemGroup(placement: .automatic) {
                // 右侧工具栏按钮
                Button(action: {
                    connectionManager.executeCurrentQuery()
                }) {
                    Label("执行", systemImage: "play.fill")
                }
                .help("执行查询 (⌘↩)")
                .disabled(!connectionManager.canExecuteQuery)
                
                Button(action: {
                    connectionManager.stopCurrentQuery()
                }) {
                    Label("停止", systemImage: "stop.fill")
                }
                .help("停止查询")
                .disabled(!connectionManager.isExecuting)
                
                Divider()
                
                Button(action: {
                    connectionManager.refreshCurrentView()
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .help("刷新当前视图")
                
                Menu {
                    Button("导入向导") {
                        connectionManager.showImportWizard = true
                    }
                    Button("导出向导") {
                        connectionManager.showExportWizard = true
                    }
                } label: {
                    Label("导入/导出", systemImage: "arrow.triangle.2.circlepath")
                }
                .help("数据导入导出")
                
                Divider()
                
                Button(action: {
                    connectionManager.showSearch = true
                }) {
                    Label("搜索", systemImage: "magnifyingglass")
                }
                .help("搜索数据库对象")
            }
        }
        .searchable(text: $connectionManager.searchText, prompt: "搜索表、视图、存储过程...")
        .sheet(isPresented: $connectionManager.showNewConnectionDialog) {
            ConnectionDialog()
        }
        .sheet(isPresented: $connectionManager.showImportWizard) {
            ImportWizard()
        }
        .sheet(isPresented: $connectionManager.showExportWizard) {
            ExportWizard()
        }
        .alert("错误", isPresented: $connectionManager.showError) {
            Button("确定") { }
        } message: {
            Text(connectionManager.errorMessage)
        }
    }
}

// 侧边栏视图
struct SidebarView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        List(selection: $connectionManager.selectedItem) {
            Section("连接") {
                ForEach(connectionManager.connections) { connection in
                    ConnectionCell(connection: connection)
                        .tag(NavigationItem.connection(connection))
                }
            }
            
            if let activeConnection = connectionManager.activeConnection {
                Section("数据库") {
                    ForEach(activeConnection.databases) { database in
                        DisclosureGroup {
                            // 表
                            ForEach(database.tables) { table in
                                Label(table.name, systemImage: "tablecells")
                                    .tag(NavigationItem.table(table))
                            }
                            
                            // 视图
                            ForEach(database.views) { view in
                                Label(view.name, systemImage: "eye")
                                    .tag(NavigationItem.view(view))
                            }
                            
                            // 存储过程
                            ForEach(database.procedures) { procedure in
                                Label(procedure.name, systemImage: "function")
                                    .tag(NavigationItem.procedure(procedure))
                            }
                        } label: {
                            Label(database.name, systemImage: "database")
                                .tag(NavigationItem.database(database))
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    connectionManager.refreshSidebar()
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
            }
        }
    }
}

// 内容列表视图
struct ContentListView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        List(selection: $connectionManager.selectedContentItem) {
            if let database = connectionManager.selectedDatabase {
                Section("表 (\(database.tables.count))") {
                    ForEach(database.tables) { table in
                        Label {
                            Text(table.name)
                        } icon: {
                            Image(systemName: "tablecells")
                                .foregroundColor(.blue)
                        }
                        .tag(ContentItem.table(table))
                    }
                }
                
                Section("视图 (\(database.views.count))") {
                    ForEach(database.views) { view in
                        Label {
                            Text(view.name)
                        } icon: {
                            Image(systemName: "eye")
                                .foregroundColor(.green)
                        }
                        .tag(ContentItem.view(view))
                    }
                }
                
                Section("存储过程 (\(database.procedures.count))") {
                    ForEach(database.procedures) { procedure in
                        Label {
                            Text(procedure.name)
                        } icon: {
                            Image(systemName: "function")
                                .foregroundColor(.orange)
                        }
                        .tag(ContentItem.procedure(procedure))
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("未选择数据库", systemImage: "database")
                } description: {
                    Text("请从左侧选择一个数据库连接")
                }
            }
        }
        .listStyle(.inset)
    }
}

// 详情视图
struct DetailView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        TabView(selection: $connectionManager.selectedTab) {
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

// 导航项枚举
enum NavigationItem: Hashable {
    case connection(Connection)
    case database(Database)
    case table(Table)
    case view(DatabaseView)
    case procedure(StoredProcedure)
    case function(Function)
}

// 内容项枚举
enum ContentItem: Hashable {
    case table(Table)
    case view(DatabaseView)
    case procedure(StoredProcedure)
    case function(Function)
}

// 标签页枚举
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

#Preview {
    MainView()
        .environmentObject(ConnectionManager())
}