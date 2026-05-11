import SwiftUI

// 导入向导
struct ImportWizard: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedStep: ImportStep = .selectFile
    @State private var selectedFileType: FileType = .csv
    @State private var selectedFile: URL?
    @State private var previewData: [[String]] = []
    @State private var columns: [String] = []
    @State private var selectedTable: String = ""
    @State private var importMode: ImportMode = .insert
    @State private var fieldMapping: [FieldMapping] = []
    @State private var isImporting: Bool = false
    @State private var importProgress: Double = 0
    @State private var importResult: ImportResult?
    
    enum ImportStep: Int, CaseIterable {
        case selectFile = 1
        case preview = 2
        case configure = 3
        case mapping = 4
        case execute = 5
    }
    
    enum FileType: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case excel = "Excel"
        case sql = "SQL"
    }
    
    enum ImportMode: String, CaseIterable {
        case insert = "插入"
        case update = "更新"
        case insertUpdate = "插入或更新"
        case replace = "替换"
    }
    
    struct FieldMapping: Identifiable {
        let id = UUID()
        var sourceField: String
        var targetField: String
        var dataType: String
        var defaultValue: String?
    }
    
    enum ImportResult {
        case success(rows: Int)
        case failure(error: String)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("导入向导")
                    .font(.headline)
                Spacer()
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            
            // 步骤指示器
            stepIndicator
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            // 内容区域
            TabView(selection: $selectedStep) {
                // 步骤1: 选择文件
                selectFileStep
                    .tag(ImportStep.selectFile)
                
                // 步骤2: 预览数据
                previewStep
                    .tag(ImportStep.preview)
                
                // 步骤3: 配置选项
                configureStep
                    .tag(ImportStep.configure)
                
                // 步骤4: 字段映射
                mappingStep
                    .tag(ImportStep.mapping)
                
                // 步骤5: 执行导入
                executeStep
                    .tag(ImportStep.execute)
            }
            .tabViewStyle(.automatic)
            .padding(.horizontal)
            
            // 底部按钮
            HStack {
                Button("上一步") {
                    previousStep()
                }
                .disabled(selectedStep == .selectFile)
                
                Spacer()
                
                Button(selectedStep == .execute ? "完成" : "下一步") {
                    if selectedStep == .execute {
                        dismiss()
                    } else {
                        nextStep()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canProceed)
            }
            .padding()
        }
        .frame(width: 700, height: 600)
    }
    
    // 步骤指示器
    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(ImportStep.allCases, id: \.self) { step in
                HStack(spacing: 0) {
                    // 步骤圆圈
                    ZStack {
                        Circle()
                            .fill(step.rawValue <= selectedStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                        
                        Text("\(step.rawValue)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    // 步骤标签
                    Text(stepTitle(step))
                        .font(.caption)
                        .foregroundColor(step.rawValue <= selectedStep.rawValue ? .primary : .secondary)
                        .padding(.leading, 5)
                    
                    // 连接线
                    if step.rawValue < ImportStep.allCases.count {
                        Rectangle()
                            .fill(step.rawValue < selectedStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .padding(.horizontal, 10)
                    }
                }
            }
        }
    }
    
    // 步骤标题
    private func stepTitle(_ step: ImportStep) -> String {
        switch step {
        case .selectFile: return "选择文件"
        case .preview: return "预览"
        case .configure: return "配置"
        case .mapping: return "映射"
        case .execute: return "执行"
        }
    }
    
    // 步骤1: 选择文件
    private var selectFileStep: some View {
        VStack(spacing: 20) {
            // 文件类型选择
            GroupBox("文件类型") {
                Picker("文件类型", selection: $selectedFileType) {
                    ForEach(FileType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            // 文件选择
            GroupBox("选择文件") {
                VStack {
                    if let file = selectedFile {
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.blue)
                            Text(file.lastPathComponent)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button("更改") {
                                selectFile()
                            }
                        }
                    } else {
                        Button("选择文件...") {
                            selectFile()
                        }
                    }
                }
                .padding()
            }
            
            // 文件信息
            if let file = selectedFile {
                GroupBox("文件信息") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("文件名:")
                                .frame(width: 80, alignment: .trailing)
                            Text(file.lastPathComponent)
                        }
                        
                        HStack {
                            Text("文件大小:")
                                .frame(width: 80, alignment: .trailing)
                            Text(fileSize(file))
                        }
                        
                        HStack {
                            Text("文件类型:")
                                .frame(width: 80, alignment: .trailing)
                            Text(selectedFileType.rawValue)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // 步骤2: 预览数据
    private var previewStep: some View {
        VStack(spacing: 20) {
            // 预览选项
            GroupBox("预览选项") {
                HStack {
                    Text("预览行数:")
                    TextField("10", text: .constant("10"))
                        .frame(width: 60)
                    
                    Spacer()
                    
                    Button("刷新预览") {
                        loadPreview()
                    }
                }
                .padding()
            }
            
            // 数据预览
            GroupBox("数据预览") {
                if previewData.isEmpty {
                    ContentUnavailableView {
                        Label("无预览数据", systemImage: "tablecells")
                    } description: {
                        Text("请先选择文件")
                    }
                } else {
                    ScrollView([.horizontal, .vertical]) {
                        LazyVGrid(columns: previewColumns, spacing: 0) {
                            // 表头
                            ForEach(columns, id: \.self) { column in
                                Text(column)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color(.controlBackgroundColor))
                                    .border(Color(.separatorColor), width: 0.5)
                            }
                            
                            // 数据行
                            ForEach(0..<min(previewData.count, 10), id: \.self) { row in
                                ForEach(0..<previewData[row].count, id: \.self) { column in
                                    Text(previewData[row][column])
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
                    .frame(height: 200)
                }
            }
        }
    }
    
    // 预览列
    private var previewColumns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 0), count: columns.count)
    }
    
    // 步骤3: 配置选项
    private var configureStep: some View {
        Form {
            Section("目标表") {
                HStack {
                    Text("目标表:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("输入表名", text: $selectedTable)
                }
            }
            
            Section("导入模式") {
                Picker("导入模式", selection: $importMode) {
                    ForEach(ImportMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
            }
            
            Section("导入选项") {
                Toggle("包含列名行", isOn: .constant(true))
                Toggle("忽略错误", isOn: .constant(false))
                Toggle("使用事务", isOn: .constant(true))
                
                HStack {
                    Text("字符集:")
                        .frame(width: 80, alignment: .trailing)
                    Picker("", selection: .constant("utf8mb4")) {
                        Text("utf8mb4").tag("utf8mb4")
                        Text("utf8").tag("utf8")
                        Text("latin1").tag("latin1")
                    }
                    .frame(width: 150)
                }
                
                HStack {
                    Text("分隔符:")
                        .frame(width: 80, alignment: .trailing)
                    TextField(",", text: .constant(","))
                        .frame(width: 100)
                }
                
                HStack {
                    Text("文本限定符:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("\"", text: .constant("\""))
                        .frame(width: 100)
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // 步骤4: 字段映射
    private var mappingStep: some View {
        VStack(spacing: 20) {
            // 映射说明
            GroupBox("字段映射") {
                Text("将源文件字段映射到目标表字段")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            // 映射表格
            List {
                ForEach(fieldMapping) { mapping in
                    HStack {
                        // 源字段
                        Text(mapping.sourceField)
                            .frame(minWidth: 100, alignment: .leading)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.blue)
                        
                        // 目标字段
                        Picker("", selection: .constant(mapping.targetField)) {
                            Text("选择目标字段").tag("")
                            ForEach(columns, id: \.self) { column in
                                Text(column).tag(column)
                            }
                        }
                        .frame(width: 150)
                        
                        // 数据类型
                        Text(mapping.dataType)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // 默认值
                        HStack {
                            Text("默认值:")
                            TextField("可选", text: .constant(mapping.defaultValue ?? ""))
                                .frame(width: 100)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // 步骤5: 执行导入
    private var executeStep: some View {
        VStack(spacing: 20) {
            if isImporting {
                // 导入进度
                GroupBox("导入进度") {
                    VStack {
                        ProgressView(value: importProgress)
                            .progressViewStyle(.linear)
                        
                        Text("正在导入数据...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(importProgress * 100))%")
                            .font(.headline)
                    }
                    .padding()
                }
            } else if let result = importResult {
                // 导入结果
                GroupBox("导入结果") {
                    Group {
                        switch result {
                        case .success(let rows):
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 50))
                                
                                Text("导入成功")
                                    .font(.headline)
                                
                                Text("成功导入 \(rows) 行数据")
                                    .foregroundColor(.secondary)
                            }
                        case .failure(let error):
                            VStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 50))
                                
                                Text("导入失败")
                                    .font(.headline)
                                
                                Text(error)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // 准备导入
                GroupBox("准备导入") {
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("准备导入数据")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("源文件:")
                                    .frame(width: 80, alignment: .trailing)
                                Text(selectedFile?.lastPathComponent ?? "未选择")
                            }
                            
                            HStack {
                                Text("目标表:")
                                    .frame(width: 80, alignment: .trailing)
                                Text(selectedTable)
                            }
                            
                            HStack {
                                Text("导入模式:")
                                    .frame(width: 80, alignment: .trailing)
                                Text(importMode.rawValue)
                            }
                            
                            HStack {
                                Text("预估行数:")
                                    .frame(width: 80, alignment: .trailing)
                                Text("\(previewData.count)")
                            }
                        }
                        
                        Button("开始导入") {
                            startImport()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
        }
    }
    
    // 是否可以继续
    private var canProceed: Bool {
        switch selectedStep {
        case .selectFile:
            return selectedFile != nil
        case .preview:
            return !previewData.isEmpty
        case .configure:
            return !selectedTable.isEmpty
        case .mapping:
            return true
        case .execute:
            return true
        }
    }
    
    // 下一步
    private func nextStep() {
        if let nextStep = ImportStep(rawValue: selectedStep.rawValue + 1) {
            selectedStep = nextStep
            
            // 执行步骤特定的操作
            switch nextStep {
            case .preview:
                loadPreview()
            case .configure:
                loadTableList()
            case .mapping:
                setupFieldMapping()
            case .execute:
                break
            default:
                break
            }
        }
    }
    
    // 上一步
    private func previousStep() {
        if let prevStep = ImportStep(rawValue: selectedStep.rawValue - 1) {
            selectedStep = prevStep
        }
    }
    
    // 选择文件
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.commaSeparatedText, .json, .spreadsheet, .plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            selectedFile = panel.url
        }
    }
    
    // 文件大小
    private func fileSize(_ url: URL) -> String {
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
            return "未知"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(size))
    }
    
    // 加载预览
    private func loadPreview() {
        guard let file = selectedFile else { return }
        
        // 模拟加载预览数据
        columns = ["id", "name", "email", "created_at"]
        previewData = [
            ["1", "张三", "zhangsan@example.com", "2024-01-01"],
            ["2", "李四", "lisi@example.com", "2024-01-02"],
            ["3", "王五", "wangwu@example.com", "2024-01-03"]
        ]
    }
    
    // 加载表列表
    private func loadTableList() {
        // 模拟加载表列表
        selectedTable = "users"
    }
    
    // 设置字段映射
    private func setupFieldMapping() {
        fieldMapping = columns.map { column in
            FieldMapping(
                sourceField: column,
                targetField: column,
                dataType: "VARCHAR(255)",
                defaultValue: nil
            )
        }
    }
    
    // 开始导入
    private func startImport() {
        isImporting = true
        importProgress = 0
        
        // 模拟导入过程
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            importProgress += 0.05
            
            if importProgress >= 1.0 {
                timer.invalidate()
                isImporting = false
                importResult = .success(rows: previewData.count)
            }
        }
    }
}

// 导出向导
struct ExportWizard: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedStep: ExportStep = .selectTable
    @State private var selectedTables: Set<String> = []
    @State private var selectedFormat: ExportFormat = .csv
    @State private var exportOptions: ExportOptions = ExportOptions()
    @State private var isExporting: Bool = false
    @State private var exportProgress: Double = 0
    @State private var exportResult: ExportResult?
    @State private var exportFile: URL?
    
    enum ExportStep: Int, CaseIterable {
        case selectTable = 1
        case configure = 2
        case execute = 3
    }
    
    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case excel = "Excel"
        case sql = "SQL"
    }
    
    struct ExportOptions {
        var includeHeaders: Bool = true
        var delimiter: String = ","
        var textQualifier: String = "\""
        var charset: String = "utf8mb4"
        var whereClause: String = ""
        var limit: String = ""
        var orderBy: String = ""
    }
    
    enum ExportResult {
        case success(file: URL, rows: Int)
        case failure(error: String)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("导出向导")
                    .font(.headline)
                Spacer()
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            
            // 步骤指示器
            stepIndicator
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            // 内容区域
            TabView(selection: $selectedStep) {
                // 步骤1: 选择表
                selectTableStep
                    .tag(ExportStep.selectTable)
                
                // 步骤2: 配置选项
                configureStep
                    .tag(ExportStep.configure)
                
                // 步骤3: 执行导出
                executeStep
                    .tag(ExportStep.execute)
            }
            .tabViewStyle(.automatic)
            .padding(.horizontal)
            
            // 底部按钮
            HStack {
                Button("上一步") {
                    previousStep()
                }
                .disabled(selectedStep == .selectTable)
                
                Spacer()
                
                Button(selectedStep == .execute ? "完成" : "下一步") {
                    if selectedStep == .execute {
                        dismiss()
                    } else {
                        nextStep()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canProceed)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
    
    // 步骤指示器
    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(ExportStep.allCases, id: \.self) { step in
                HStack(spacing: 0) {
                    // 步骤圆圈
                    ZStack {
                        Circle()
                            .fill(step.rawValue <= selectedStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                        
                        Text("\(step.rawValue)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    // 步骤标签
                    Text(stepTitle(step))
                        .font(.caption)
                        .foregroundColor(step.rawValue <= selectedStep.rawValue ? .primary : .secondary)
                        .padding(.leading, 5)
                    
                    // 连接线
                    if step.rawValue < ExportStep.allCases.count {
                        Rectangle()
                            .fill(step.rawValue < selectedStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .padding(.horizontal, 10)
                    }
                }
            }
        }
    }
    
    // 步骤标题
    private func stepTitle(_ step: ExportStep) -> String {
        switch step {
        case .selectTable: return "选择表"
        case .configure: return "配置"
        case .execute: return "执行"
        }
    }
    
    // 步骤1: 选择表
    private var selectTableStep: some View {
        VStack(spacing: 20) {
            // 数据库选择
            GroupBox("数据库") {
                HStack {
                    Text("数据库:")
                        .frame(width: 80, alignment: .trailing)
                    Picker("", selection: .constant("test_db")) {
                        Text("test_db").tag("test_db")
                        Text("mysql").tag("mysql")
                    }
                    .frame(width: 200)
                }
                .padding()
            }
            
            // 表选择
            GroupBox("选择表") {
                List {
                    ForEach(["users", "orders", "products"], id: \.self) { table in
                        HStack {
                            Image(systemName: selectedTables.contains(table) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedTables.contains(table) ? .blue : .gray)
                            
                            Image(systemName: "tablecells")
                                .foregroundColor(.blue)
                            
                            Text(table)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTables.contains(table) {
                                selectedTables.remove(table)
                            } else {
                                selectedTables.insert(table)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }
    
    // 步骤2: 配置选项
    private var configureStep: some View {
        Form {
            Section("导出格式") {
                Picker("导出格式", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.radioGroup)
            }
            
            Section("导出选项") {
                Toggle("包含列名行", isOn: $exportOptions.includeHeaders)
                
                if selectedFormat == .csv {
                    HStack {
                        Text("分隔符:")
                            .frame(width: 80, alignment: .trailing)
                        TextField(",", text: $exportOptions.delimiter)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("文本限定符:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("\"", text: $exportOptions.textQualifier)
                            .frame(width: 100)
                    }
                }
                
                HStack {
                    Text("字符集:")
                        .frame(width: 80, alignment: .trailing)
                    Picker("", selection: $exportOptions.charset) {
                        Text("utf8mb4").tag("utf8mb4")
                        Text("utf8").tag("utf8")
                        Text("latin1").tag("latin1")
                    }
                    .frame(width: 150)
                }
            }
            
            Section("数据筛选") {
                HStack {
                    Text("WHERE条件:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("可选", text: $exportOptions.whereClause)
                }
                
                HStack {
                    Text("LIMIT:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("可选", text: $exportOptions.limit)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("ORDER BY:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("可选", text: $exportOptions.orderBy)
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // 步骤3: 执行导出
    private var executeStep: some View {
        VStack(spacing: 20) {
            if isExporting {
                // 导出进度
                GroupBox("导出进度") {
                    VStack {
                        ProgressView(value: exportProgress)
                            .progressViewStyle(.linear)
                        
                        Text("正在导出数据...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(exportProgress * 100))%")
                            .font(.headline)
                    }
                    .padding()
                }
            } else if let result = exportResult {
                // 导出结果
                GroupBox("导出结果") {
                    Group {
                        switch result {
                        case .success(let file, let rows):
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 50))
                                
                                Text("导出成功")
                                    .font(.headline)
                                
                                Text("成功导出 \(rows) 行数据")
                                    .foregroundColor(.secondary)
                                
                                Text("文件: \(file.lastPathComponent)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("打开文件") {
                                    NSWorkspace.shared.open(file)
                                }
                                .buttonStyle(.bordered)
                            }
                        case .failure(let error):
                            VStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 50))
                                
                                Text("导出失败")
                                    .font(.headline)
                                
                                Text(error)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // 准备导出
                GroupBox("准备导出") {
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.up.doc.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("准备导出数据")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("选择的表:")
                                    .frame(width: 80, alignment: .trailing)
                                Text("\(selectedTables.count) 个")
                            }
                            
                            HStack {
                                Text("导出格式:")
                                    .frame(width: 80, alignment: .trailing)
                                Text(selectedFormat.rawValue)
                            }
                        }
                        
                        Button("开始导出") {
                            startExport()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
        }
    }
    
    // 是否可以继续
    private var canProceed: Bool {
        switch selectedStep {
        case .selectTable:
            return !selectedTables.isEmpty
        case .configure:
            return true
        case .execute:
            return true
        }
    }
    
    // 下一步
    private func nextStep() {
        if let nextStep = ExportStep(rawValue: selectedStep.rawValue + 1) {
            selectedStep = nextStep
        }
    }
    
    // 上一步
    private func previousStep() {
        if let prevStep = ExportStep(rawValue: selectedStep.rawValue - 1) {
            selectedStep = prevStep
        }
    }
    
    // 开始导出
    private func startExport() {
        isExporting = true
        exportProgress = 0
        
        // 模拟导出过程
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            exportProgress += 0.05
            
            if exportProgress >= 1.0 {
                timer.invalidate()
                isExporting = false
                
                // 模拟导出结果
                let file = FileManager.default.temporaryDirectory.appendingPathComponent("export_\(Date().timeIntervalSince1970).\(selectedFormat.rawValue.lowercased())")
                exportResult = .success(file: file, rows: 1000)
            }
        }
    }
}

#Preview {
    ImportWizard()
        .environmentObject(ConnectionManager())
}