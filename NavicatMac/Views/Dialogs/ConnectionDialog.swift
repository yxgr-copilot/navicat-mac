import SwiftUI

// 连接对话框
struct ConnectionDialog: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @Environment(\.dismiss) var dismiss
    
    @State private var connectionName: String = ""
    @State private var host: String = "localhost"
    @State private var port: String = "3306"
    @State private var username: String = "root"
    @State private var password: String = ""
    @State private var database: String = ""
    @State private var color: String = "#007AFF"
    @State private var group: String = ""
    
    @State private var sshEnabled: Bool = false
    @State private var sshHost: String = ""
    @State private var sshPort: String = "22"
    @State private var sshUsername: String = ""
    @State private var sshPassword: String = ""
    
    @State private var sslEnabled: Bool = false
    
    @State private var isTesting: Bool = false
    @State private var testResult: TestResult?
    
    @State private var selectedTab: ConnectionTab = .general
    
    enum ConnectionTab: String, CaseIterable {
        case general = "常规"
        case ssh = "SSH"
        case ssl = "SSL"
        case http = "HTTP"
        case advanced = "高级"
    }
    
    enum TestResult {
        case success
        case failure(String)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("新建连接")
                    .font(.headline)
                Spacer()
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            
            // 连接类型选择
            HStack {
                Image(systemName: "server.rack")
                    .foregroundColor(.blue)
                Text("MySQL")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // 标签页选择器
            Picker("设置", selection: $selectedTab) {
                ForEach(ConnectionTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 15)
            
            // 内容区域
            TabView(selection: $selectedTab) {
                // 常规设置
                generalTab
                    .tag(ConnectionTab.general)
                
                // SSH设置
                sshTab
                    .tag(ConnectionTab.ssh)
                
                // SSL设置
                sslTab
                    .tag(ConnectionTab.ssl)
                
                // HTTP设置
                httpTab
                    .tag(ConnectionTab.http)
                
                // 高级设置
                advancedTab
                    .tag(ConnectionTab.advanced)
            }
            .tabViewStyle(.automatic)
            .padding(.horizontal)
            
            // 底部按钮
            HStack {
                Button("测试连接") {
                    testConnection()
                }
                .disabled(isTesting)
                
                if isTesting {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                if let result = testResult {
                    switch result {
                    case .success:
                        Label("连接成功", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    case .failure(let error):
                        Label(error, systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                Button("确定") {
                    saveConnection()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(connectionName.isEmpty || host.isEmpty || username.isEmpty)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
    }
    
    // 常规设置标签页
    private var generalTab: some View {
        Form {
            Section("连接信息") {
                HStack {
                    Text("连接名:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("输入连接名称", text: $connectionName)
                }
                
                HStack {
                    Text("颜色:")
                        .frame(width: 80, alignment: .trailing)
                    ColorPicker("", selection: .constant(Color(hex: color) ?? .blue))
                        .labelsHidden()
                    TextField("#007AFF", text: $color)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("分组:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("输入分组名称（可选）", text: $group)
                }
            }
            
            Section("主机设置") {
                HStack {
                    Text("主机名:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("localhost", text: $host)
                }
                
                HStack {
                    Text("端口:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("3306", text: $port)
                        .frame(width: 100)
                }
            }
            
            Section("认证") {
                HStack {
                    Text("用户名:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("root", text: $username)
                }
                
                HStack {
                    Text("密码:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("输入密码", text: $password)
                }
                
                HStack {
                    Text("数据库:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("输入数据库名（可选）", text: $database)
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // SSH设置标签页
    private var sshTab: some View {
        Form {
            Section("SSH隧道") {
                Toggle("使用SSH隧道", isOn: $sshEnabled)
                
                if sshEnabled {
                    HStack {
                        Text("主机名:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("SSH服务器地址", text: $sshHost)
                    }
                    
                    HStack {
                        Text("端口:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("22", text: $sshPort)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("用户名:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("SSH用户名", text: $sshUsername)
                    }
                    
                    HStack {
                        Text("密码:")
                            .frame(width: 80, alignment: .trailing)
                        SecureField("SSH密码", text: $sshPassword)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // SSL设置标签页
    private var sslTab: some View {
        Form {
            Section("SSL设置") {
                Toggle("使用SSL", isOn: $sslEnabled)
                
                if sslEnabled {
                    HStack {
                        Text("客户端证书:")
                            .frame(width: 100, alignment: .trailing)
                        Button("选择文件") {
                            // 选择证书文件
                        }
                    }
                    
                    HStack {
                        Text("客户端密钥:")
                            .frame(width: 100, alignment: .trailing)
                        Button("选择文件") {
                            // 选择密钥文件
                        }
                    }
                    
                    HStack {
                        Text("CA证书:")
                            .frame(width: 100, alignment: .trailing)
                        Button("选择文件") {
                            // 选择CA证书文件
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // HTTP设置标签页
    private var httpTab: some View {
        Form {
            Section("HTTP隧道") {
                Toggle("使用HTTP隧道", isOn: .constant(false))
                
                HStack {
                    Text("隧道URL:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("http://example.com/tunnel", text: .constant(""))
                }
                
                HStack {
                    Text("用户名:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("HTTP用户名", text: .constant(""))
                }
                
                HStack {
                    Text("密码:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("HTTP密码", text: .constant(""))
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // 高级设置标签页
    private var advancedTab: some View {
        Form {
            Section("高级设置") {
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
                    Text("排序规则:")
                        .frame(width: 80, alignment: .trailing)
                    Picker("", selection: .constant("utf8mb4_unicode_ci")) {
                        Text("utf8mb4_unicode_ci").tag("utf8mb4_unicode_ci")
                        Text("utf8mb4_general_ci").tag("utf8mb4_general_ci")
                        Text("utf8_general_ci").tag("utf8_general_ci")
                    }
                    .frame(width: 200)
                }
                
                HStack {
                    Text("连接超时:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("10", text: .constant("10"))
                        .frame(width: 60)
                    Text("秒")
                }
                
                HStack {
                    Text("读取超时:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("30", text: .constant("30"))
                        .frame(width: 60)
                    Text("秒")
                }
                
                Toggle("保持连接", isOn: .constant(true))
                
                HStack {
                    Text("保持间隔:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("60", text: .constant("60"))
                        .frame(width: 60)
                    Text("秒")
                }
            }
            
            Section("初始化命令") {
                TextEditor(text: .constant(""))
                    .frame(height: 100)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .formStyle(.grouped)
    }
    
    // 测试连接
    private func testConnection() {
        isTesting = true
        testResult = nil
        
        let connection = createConnection()
        
        Task {
            do {
                let success = try await connectionManager.testConnection(connection)
                
                await MainActor.run {
                    isTesting = false
                    if success {
                        testResult = .success
                    } else {
                        testResult = .failure("连接失败")
                    }
                }
            } catch {
                await MainActor.run {
                    isTesting = false
                    testResult = .failure(error.localizedDescription)
                }
            }
        }
    }
    
    // 保存连接
    private func saveConnection() {
        let connection = createConnection()
        connectionManager.addConnection(connection)
        dismiss()
    }
    
    // 创建连接对象
    private func createConnection() -> Connection {
        return Connection(
            name: connectionName.isEmpty ? "\(username)@\(host)" : connectionName,
            host: host,
            port: Int(port) ?? 3306,
            username: username,
            password: password,
            database: database.isEmpty ? nil : database,
            color: color.isEmpty ? nil : color,
            group: group.isEmpty ? nil : group,
            sshEnabled: sshEnabled,
            sshHost: sshHost.isEmpty ? nil : sshHost,
            sshPort: Int(sshPort) ?? 22,
            sshUsername: sshUsername.isEmpty ? nil : sshUsername,
            sshPassword: sshPassword.isEmpty ? nil : sshPassword,
            sslEnabled: sslEnabled
        )
    }
}

// 连接单元格
struct ConnectionCell: View {
    let connection: Connection
    
    var body: some View {
        HStack {
            // 连接图标
            Image(systemName: connection.isConnected ? "server.rack" : "server.rack")
                .foregroundColor(connection.isConnected ? .green : .gray)
                .frame(width: 20)
            
            // 连接颜色标记
            Circle()
                .fill(connection.connectionColor)
                .frame(width: 8, height: 8)
            
            // 连接名称
            VStack(alignment: .leading) {
                Text(connection.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(connection.username)@\(connection.host):\(connection.port)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 连接状态
            if connection.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConnectionDialog()
        .environmentObject(ConnectionManager())
}