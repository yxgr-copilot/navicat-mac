import SwiftUI

// 查询编辑器视图
struct QueryEditorView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @ObservedObject var tab: QueryTab
    
    @State private var query: String = ""
    @State private var selectedResultTab: ResultTab = .results
    @State private var showingHistory: Bool = false
    @State private var showingBookmarks: Bool = false
    
    enum ResultTab: String, CaseIterable {
        case results = "结果"
        case messages = "消息"
        case explain = "执行计划"
        case history = "历史记录"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 查询工具栏
            queryToolbar
            
            // SQL编辑器
            sqlEditor
            
            // 分隔线
            Divider()
            
            // 结果区域
            resultArea
        }
        .onAppear {
            query = tab.query
        }
        .onChange(of: query) { newValue in
            tab.query = newValue
        }
    }
    
    // 查询工具栏
    private var queryToolbar: some View {
        HStack(spacing: 10) {
            // 执行按钮
            Button(action: {
                connectionManager.executeCurrentQuery()
            }) {
                Label("执行", systemImage: "play.fill")
                    .foregroundColor(.green)
            }
            .buttonStyle(.bordered)
            .disabled(query.isEmpty || connectionManager.isExecuting)
            
            // 执行选中部分按钮
            Button(action: {
                connectionManager.executeSelectedQuery()
            }) {
                Label("执行选中", systemImage: "play.rectangle")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.bordered)
            .disabled(query.isEmpty || connectionManager.isExecuting)
            
            // 停止按钮
            Button(action: {
                connectionManager.stopCurrentQuery()
            }) {
                Label("停止", systemImage: "stop.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.bordered)
            .disabled(!connectionManager.isExecuting)
            
            Divider()
                .frame(height: 20)
            
            // 格式化按钮
            Button(action: {
                formatQuery()
            }) {
                Label("格式化", systemImage: "text.alignleft")
            }
            .buttonStyle(.bordered)
            
            // 清除按钮
            Button(action: {
                query = ""
            }) {
                Label("清除", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.bordered)
            
            Divider()
                .frame(height: 20)
            
            // 历史记录按钮
            Button(action: {
                showingHistory.toggle()
            }) {
                Label("历史", systemImage: "clock")
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showingHistory) {
                historyPopover
            }
            
            // 书签按钮
            Button(action: {
                showingBookmarks.toggle()
            }) {
                Label("书签", systemImage: "bookmark")
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showingBookmarks) {
                bookmarksPopover
            }
            
            Spacer()
            
            // 查询信息
            if !query.isEmpty {
                Text("字符数: \(query.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
    }
    
    // SQL编辑器
    private var sqlEditor: some View {
        VStack(spacing: 0) {
            // 行号和编辑器
            HStack(spacing: 0) {
                // 行号
                lineNumbers
                    .frame(width: 40)
                    .background(Color(.textBackgroundColor).opacity(0.5))
                
                // SQL文本编辑器
                TextEditor(text: $query)
                    .font(.system(.body, design: .monospaced))
                    .disableAutocorrection(true)
                    .frame(minHeight: 200)
                    .background(Color(.textBackgroundColor))
            }
        }
    }
    
    // 行号
    private var lineNumbers: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(0..<lineCount, id: \.self) { line in
                Text("\(line + 1)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(height: 20)
                    .padding(.trailing, 5)
            }
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // 行数
    private var lineCount: Int {
        return query.components(separatedBy: .newlines).count
    }
    
    // 结果区域
    private var resultArea: some View {
        VStack(spacing: 0) {
            // 结果标签页
            Picker("结果", selection: $selectedResultTab) {
                ForEach(ResultTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            // 结果内容
            TabView(selection: $selectedResultTab) {
                // 结果标签页
                resultsTab
                    .tag(ResultTab.results)
                
                // 消息标签页
                messagesTab
                    .tag(ResultTab.messages)
                
                // 执行计划标签页
                explainTab
                    .tag(ResultTab.explain)
                
                // 历史记录标签页
                historyTab
                    .tag(ResultTab.history)
            }
            .tabViewStyle(.automatic)
        }
        .frame(minHeight: 200)
    }
    
    // 结果标签页
    private var resultsTab: some View {
        VStack {
            if tab.results.isEmpty {
                ContentUnavailableView {
                    Label("无结果", systemImage: "doc.text.magnifyingglass")
                } description: {
                    Text("执行查询以查看结果")
                }
            } else {
                // 结果表格
                resultTable
            }
        }
    }
    
    // 结果表格
    private var resultTable: some View {
        VStack(spacing: 0) {
            // 结果工具栏
            HStack {
                Text("结果: \(tab.results.last?.rowCount ?? 0) 行")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("导出") {
                    // 导出结果
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("复制") {
                    // 复制结果
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.controlBackgroundColor))
            
            // 表格
            if let result = tab.results.last, result.hasResults {
                ScrollView([.horizontal, .vertical]) {
                    LazyVGrid(columns: gridColumns, spacing: 0) {
                        // 表头
                        ForEach(result.columns, id: \.self) { column in
                            Text(column)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color(.controlBackgroundColor))
                                .border(Color(.separatorColor), width: 0.5)
                        }
                        
                        // 数据行
                        ForEach(0..<result.rowCount, id: \.self) { row in
                            ForEach(0..<result.columns.count, id: \.self) { column in
                                Text(cellValue(result.rows[row][column]))
                                    .font(.body)
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(row % 2 == 0 ? Color(.textBackgroundColor) : Color(.controlBackgroundColor))
                                    .border(Color(.separatorColor), width: 0.5)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 网格列
    private var gridColumns: [GridItem] {
        guard let result = tab.results.last else { return [] }
        return Array(repeating: GridItem(.flexible(), spacing: 0), count: result.columns.count)
    }
    
    // 单元格值
    private func cellValue(_ value: Any?) -> String {
        if let value = value {
            return "\(value)"
        }
        return "NULL"
    }
    
    // 消息标签页
    private var messagesTab: some View {
        VStack {
            if tab.results.isEmpty {
                ContentUnavailableView {
                    Label("无消息", systemImage: "info.circle")
                } description: {
                    Text("执行查询以查看消息")
                }
            } else {
                List(tab.results) { result in
                    VStack(alignment: .leading) {
                        Text("查询: \(result.query)")
                            .font(.headline)
                        
                        if let error = result.error {
                            Text("错误: \(error.localizedDescription)")
                                .foregroundColor(.red)
                        } else {
                            Text("影响行数: \(result.affectedRows)")
                                .foregroundColor(.green)
                            
                            Text("执行时间: \(String(format: "%.3f", result.executionTime)) 秒")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // 执行计划标签页
    private var explainTab: some View {
        ContentUnavailableView {
            Label("执行计划", systemImage: "chart.bar")
        } description: {
            Text("执行EXPLAIN查询以查看执行计划")
        }
    }
    
    // 历史记录标签页
    private var historyTab: some View {
        ContentUnavailableView {
            Label("历史记录", systemImage: "clock")
        } description: {
            Text("查询历史记录将显示在这里")
        }
    }
    
    // 历史记录弹出框
    private var historyPopover: some View {
        VStack(alignment: .leading) {
            Text("查询历史")
                .font(.headline)
                .padding()
            
            List {
                ForEach(0..<10, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("SELECT * FROM users WHERE id = \(index)")
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(2)
                        
                        Text("2024-01-0\(index + 1) 10:00:00")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .onTapGesture {
                        query = "SELECT * FROM users WHERE id = \(index)"
                        showingHistory = false
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
    
    // 书签弹出框
    private var bookmarksPopover: some View {
        VStack(alignment: .leading) {
            Text("查询书签")
                .font(.headline)
                .padding()
            
            List {
                ForEach(0..<5, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("查询 \(index + 1)")
                            .font(.headline)
                        
                        Text("SELECT * FROM users")
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                    .onTapGesture {
                        query = "SELECT * FROM users"
                        showingBookmarks = false
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
    
    // 格式化查询
    private func formatQuery() {
        // 简单的SQL格式化
        let keywords = ["SELECT", "FROM", "WHERE", "AND", "OR", "ORDER BY", "GROUP BY", "HAVING", "LIMIT", "INSERT", "UPDATE", "DELETE", "CREATE", "ALTER", "DROP"]
        
        var formatted = query
        
        // 关键字大写
        for keyword in keywords {
            formatted = formatted.replacingOccurrences(
                of: keyword,
                with: keyword,
                options: .caseInsensitive
            )
        }
        
        // 在关键字后添加换行
        for keyword in ["SELECT", "FROM", "WHERE", "AND", "OR", "ORDER BY", "GROUP BY", "HAVING", "LIMIT"] {
            formatted = formatted.replacingOccurrences(
                of: " \(keyword) ",
                with: "\n\(keyword) ",
                options: .caseInsensitive
            )
        }
        
        query = formatted
    }
}

// 表数据视图
struct TableDataView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    let table: Table
    
    @State private var data: [[String: Any]] = []
    @State private var columns: [String] = []
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var sortOrder: [String: Bool] = [:]
    @State private var selectedRows: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 数据工具栏
            dataToolbar
            
            // 数据表格
            if isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if data.isEmpty {
                ContentUnavailableView {
                    Label("无数据", systemImage: "tablecells")
                } description: {
                    Text("表中没有数据")
                }
            } else {
                dataTable
            }
            
            // 状态栏
            dataStatusBar
        }
        .onAppear {
            loadData()
        }
    }
    
    // 数据工具栏
    private var dataToolbar: some View {
        HStack(spacing: 10) {
            // 刷新按钮
            Button(action: {
                loadData()
            }) {
                Label("刷新", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            
            // 添加行按钮
            Button(action: {
                addRow()
            }) {
                Label("添加", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            
            // 删除行按钮
            Button(action: {
                deleteSelectedRows()
            }) {
                Label("删除", systemImage: "minus")
                    .foregroundColor(.red)
            }
            .buttonStyle(.bordered)
            .disabled(selectedRows.isEmpty)
            
            Divider()
                .frame(height: 20)
            
            // 搜索
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            }
            
            Spacer()
            
            // 导出按钮
            Button(action: {
                exportData()
            }) {
                Label("导出", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
    }
    
    // 数据表格
    private var dataTable: some View {
        ScrollView([.horizontal, .vertical]) {
            LazyVGrid(columns: gridColumns, spacing: 0) {
                // 表头
                ForEach(columns, id: \.self) { column in
                    HStack {
                        Text(column)
                            .font(.headline)
                        
                        Spacer()
                        
                        // 排序按钮
                        Button(action: {
                            toggleSort(column)
                        }) {
                            Image(systemName: sortOrder[column] == true ? "arrow.up" : sortOrder[column] == false ? "arrow.down" : "arrow.up.arrow.down")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color(.controlBackgroundColor))
                    .border(Color(.separatorColor), width: 0.5)
                }
                
                // 数据行
                ForEach(0..<data.count, id: \.self) { row in
                    ForEach(columns, id: \.self) { column in
                        HStack {
                            Text(cellValue(data[row][column]))
                                .font(.body)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(selectedRows.contains(row) ? Color.accentColor.opacity(0.2) : (row % 2 == 0 ? Color(.textBackgroundColor) : Color(.controlBackgroundColor)))
                        .border(Color(.separatorColor), width: 0.5)
                        .onTapGesture {
                            if NSEvent.modifierFlags.contains(.command) {
                                // 多选
                                if selectedRows.contains(row) {
                                    selectedRows.remove(row)
                                } else {
                                    selectedRows.insert(row)
                                }
                            } else {
                                // 单选
                                selectedRows = [row]
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 网格列
    private var gridColumns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 0), count: columns.count)
    }
    
    // 单元格值
    private func cellValue(_ value: Any?) -> String {
        if let value = value {
            return "\(value)"
        }
        return "NULL"
    }
    
    // 数据状态栏
    private var dataStatusBar: some View {
        HStack {
            Text("行数: \(data.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if !selectedRows.isEmpty {
                Text("选中: \(selectedRows.count) 行")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(.controlBackgroundColor))
    }
    
    // 加载数据
    private func loadData() {
        isLoading = true
        
        Task {
            do {
                // 模拟加载数据
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                await MainActor.run {
                    // 模拟数据
                    columns = ["id", "name", "email", "created_at"]
                    data = [
                        ["id": 1, "name": "张三", "email": "zhangsan@example.com", "created_at": "2024-01-01 10:00:00"],
                        ["id": 2, "name": "李四", "email": "lisi@example.com", "created_at": "2024-01-02 11:00:00"],
                        ["id": 3, "name": "王五", "email": "wangwu@example.com", "created_at": "2024-01-03 12:00:00"]
                    ]
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    // 添加行
    private func addRow() {
        // 实现添加行逻辑
    }
    
    // 删除选中的行
    private func deleteSelectedRows() {
        // 实现删除行逻辑
    }
    
    // 切换排序
    private func toggleSort(_ column: String) {
        if sortOrder[column] == nil {
            sortOrder[column] = true
        } else if sortOrder[column] == true {
            sortOrder[column] = false
        } else {
            sortOrder.removeValue(forKey: column)
        }
        
        // 应用排序
        applySort()
    }
    
    // 应用排序
    private func applySort() {
        // 实现排序逻辑
    }
    
    // 导出数据
    private func exportData() {
        // 实现导出逻辑
    }
}

// 表设计器视图
struct TableDesignerView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    let table: Table
    
    @State private var columns: [Column] = []
    @State private var indexes: [Index] = []
    @State private var foreignKeys: [ForeignKey] = []
    @State private var selectedTab: DesignerTab = .columns
    
    enum DesignerTab: String, CaseIterable {
        case columns = "字段"
        case indexes = "索引"
        case foreignKeys = "外键"
        case options = "选项"
        case ddl = "DDL"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 设计器工具栏
            designerToolbar
            
            // 标签页选择器
            Picker("设计", selection: $selectedTab) {
                ForEach(DesignerTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            // 内容区域
            TabView(selection: $selectedTab) {
                // 字段标签页
                columnsTab
                    .tag(DesignerTab.columns)
                
                // 索引标签页
                indexesTab
                    .tag(DesignerTab.indexes)
                
                // 外键标签页
                foreignKeysTab
                    .tag(DesignerTab.foreignKeys)
                
                // 选项标签页
                optionsTab
                    .tag(DesignerTab.options)
                
                // DDL标签页
                ddlTab
                    .tag(DesignerTab.ddl)
            }
            .tabViewStyle(.automatic)
        }
        .onAppear {
            loadTableStructure()
        }
    }
    
    // 设计器工具栏
    private var designerToolbar: some View {
        HStack(spacing: 10) {
            // 保存按钮
            Button(action: {
                saveChanges()
            }) {
                Label("保存", systemImage: "square.and.arrow.down")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.bordered)
            
            // 撤销按钮
            Button(action: {
                undoChanges()
            }) {
                Label("撤销", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(.bordered)
            
            // 重做按钮
            Button(action: {
                redoChanges()
            }) {
                Label("重做", systemImage: "arrow.uturn.forward")
            }
            .buttonStyle(.bordered)
            
            Divider()
                .frame(height: 20)
            
            // 添加字段按钮
            Button(action: {
                addColumn()
            }) {
                Label("添加字段", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            
            // 删除字段按钮
            Button(action: {
                deleteColumn()
            }) {
                Label("删除字段", systemImage: "minus")
                    .foregroundColor(.red)
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            // 表名
            Text("表: \(table.name)")
                .font(.headline)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
    }
    
    // 字段标签页
    private var columnsTab: some View {
        VStack(spacing: 0) {
            // 字段表格
            List {
                ForEach(columns) { column in
                    HStack {
                        // 字段名
                        Text(column.name)
                            .frame(minWidth: 100, alignment: .leading)
                        
                        // 数据类型
                        Text(column.fullDataType)
                            .frame(minWidth: 100, alignment: .leading)
                            .foregroundColor(.secondary)
                        
                        // 主键
                        if column.isPrimaryKey {
                            Image(systemName: "key.fill")
                                .foregroundColor(.yellow)
                        }
                        
                        // 非空
                        if !column.nullable {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        }
                        
                        // 自增
                        if column.isAutoIncrement {
                            Text("AI")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // 注释
                        Text(column.comment)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // 索引标签页
    private var indexesTab: some View {
        List {
            ForEach(indexes) { index in
                HStack {
                    // 索引名
                    Text(index.name)
                        .frame(minWidth: 100, alignment: .leading)
                    
                    // 索引类型
                    Text(index.isPrimary ? "PRIMARY" : index.isUnique ? "UNIQUE" : "INDEX")
                        .font(.caption)
                        .foregroundColor(index.isPrimary ? .yellow : index.isUnique ? .blue : .secondary)
                    
                    // 索引列
                    Text(index.columns.joined(separator: ", "))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 索引类型
                    Text(index.indexType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // 外键标签页
    private var foreignKeysTab: some View {
        List {
            ForEach(foreignKeys) { foreignKey in
                HStack {
                    // 外键名
                    Text(foreignKey.name)
                        .frame(minWidth: 100, alignment: .leading)
                    
                    // 本表列
                    Text(foreignKey.columns.joined(separator: ", "))
                        .foregroundColor(.secondary)
                    
                    // 引用表
                    Text("→ \(foreignKey.referencedTable)")
                        .foregroundColor(.blue)
                    
                    // 引用列
                    Text("(\(foreignKey.referencedColumns.joined(separator: ", ")))")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 删除规则
                    Text("ON DELETE \(foreignKey.onDelete)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // 选项标签页
    private var optionsTab: some View {
        Form {
            Section("表选项") {
                HStack {
                    Text("引擎:")
                        .frame(width: 80, alignment: .trailing)
                    Text(table.engine)
                }
                
                HStack {
                    Text("字符集:")
                        .frame(width: 80, alignment: .trailing)
                    Text("utf8mb4")
                }
                
                HStack {
                    Text("排序规则:")
                        .frame(width: 80, alignment: .trailing)
                    Text("utf8mb4_unicode_ci")
                }
                
                HStack {
                    Text("行数:")
                        .frame(width: 80, alignment: .trailing)
                    Text("\(table.rows)")
                }
                
                HStack {
                    Text("大小:")
                        .frame(width: 80, alignment: .trailing)
                    Text(table.size)
                }
            }
            
            Section("注释") {
                TextEditor(text: .constant(table.comment))
                    .frame(height: 100)
            }
        }
        .formStyle(.grouped)
    }
    
    // DDL标签页
    private var ddlTab: some View {
        VStack {
            TextEditor(text: .constant(generateDDL()))
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // 加载表结构
    private func loadTableStructure() {
        columns = table.columns
        indexes = table.indexes
        foreignKeys = table.foreignKeys
    }
    
    // 生成DDL
    private func generateDDL() -> String {
        var ddl = "CREATE TABLE `\(table.name)` (\n"
        
        // 字段定义
        for (index, column) in columns.enumerated() {
            ddl += "  `\(column.name)` \(column.fullDataType)"
            
            if !column.nullable {
                ddl += " NOT NULL"
            }
            
            if let defaultValue = column.defaultValue {
                ddl += " DEFAULT '\(defaultValue)'"
            }
            
            if column.isAutoIncrement {
                ddl += " AUTO_INCREMENT"
            }
            
            if !column.comment.isEmpty {
                ddl += " COMMENT '\(column.comment)'"
            }
            
            if index < columns.count - 1 {
                ddl += ","
            }
            
            ddl += "\n"
        }
        
        // 主键
        if let primaryKey = indexes.first(where: { $0.isPrimary }) {
            ddl += "  PRIMARY KEY (`\(primaryKey.columns.joined(separator: "`, `"))`),\n"
        }
        
        // 索引
        for index in indexes where !index.isPrimary {
            if index.isUnique {
                ddl += "  UNIQUE KEY `\(index.name)` (`\(index.columns.joined(separator: "`, `"))`),\n"
            } else {
                ddl += "  KEY `\(index.name)` (`\(index.columns.joined(separator: "`, `"))`),\n"
            }
        }
        
        // 外键
        for foreignKey in foreignKeys {
            ddl += "  CONSTRAINT `\(foreignKey.name)` FOREIGN KEY (`\(foreignKey.columns.joined(separator: "`, `"))`) REFERENCES `\(foreignKey.referencedTable)` (`\(foreignKey.referencedColumns.joined(separator: "`, `"))`)"
            ddl += " ON DELETE \(foreignKey.onDelete)"
            ddl += " ON UPDATE \(foreignKey.onUpdate)"
            ddl += ",\n"
        }
        
        // 移除最后一个逗号
        if ddl.hasSuffix(",\n") {
            ddl = String(ddl.dropLast(2))
            ddl += "\n"
        }
        
        ddl += ") ENGINE=\(table.engine) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
        
        if !table.comment.isEmpty {
            ddl += " COMMENT='\(table.comment)'"
        }
        
        ddl += ";"
        
        return ddl
    }
    
    // 保存更改
    private func saveChanges() {
        // 实现保存逻辑
    }
    
    // 撤销更改
    private func undoChanges() {
        // 实现撤销逻辑
    }
    
    // 重做更改
    private func redoChanges() {
        // 实现重做逻辑
    }
    
    // 添加字段
    private func addColumn() {
        // 实现添加字段逻辑
    }
    
    // 删除字段
    private func deleteColumn() {
        // 实现删除字段逻辑
    }
}

#Preview {
    QueryEditorView(tab: QueryTab())
        .environmentObject(ConnectionManager())
}