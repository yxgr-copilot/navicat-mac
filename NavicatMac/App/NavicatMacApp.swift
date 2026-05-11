import SwiftUI

@main
struct NavicatMacApp: App {
    @StateObject private var connectionManager = ConnectionManager()
    @State private var showAbout = false
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(connectionManager)
                .sheet(isPresented: $showAbout) {
                    AboutView()
                }
        }
        .windowStyle(.titleBar)
        .commands {
            // 替换关于菜单
            CommandGroup(replacing: .appInfo) {
                Button("About NavicatMac") {
                    showAbout = true
                }
            }
            
            // 菜单栏命令
            CommandGroup(replacing: .newItem) {
                Button("新建连接") {
                    connectionManager.showNewConnectionDialog = true
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("新建查询") {
                    connectionManager.createNewQuery()
                }
                .keyboardShortcut("t", modifiers: .command)
            }
            
            CommandGroup(after: .pasteboard) {
                Button("执行查询") {
                    connectionManager.executeCurrentQuery()
                }
                .keyboardShortcut(.return, modifiers: .command)
                
                Button("执行选中的查询") {
                    connectionManager.executeSelectedQuery()
                }
                .keyboardShortcut(.return, modifiers: [.command, .shift])
            }
        }
    }
}

// MARK: - 关于视图
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // 应用图标
            Image(systemName: "server.rack")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            // 应用名称
            Text("NavicatMac")
                .font(.system(size: 24, weight: .bold))
            
            // 版本号（只显示版本，不显示构建号）
            Text("Version \(appVersion)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            // 版权信息
            Text("© 2026 NavicatMac. All rights reserved.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            // 关闭按钮
            Button("OK") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.top, 10)
        }
        .padding(30)
        .frame(width: 300)
    }
    
    // 获取应用版本号（只返回CFBundleShortVersionString）
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}