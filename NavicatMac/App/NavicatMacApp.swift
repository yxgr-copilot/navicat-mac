import SwiftUI

@main
struct NavicatMacApp: App {
    @StateObject private var connectionManager = ConnectionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectionManager)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
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

// MARK: - 内容视图
struct ContentView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        MainView()
            .onAppear {
                // 设置窗口标题
                DispatchQueue.main.async {
                    NSApplication.shared.windows.forEach { window in
                        window.title = "NavicatMac"
                    }
                }
            }
    }
}