import SwiftUI

@main
struct NavicatMacApp: App {
    @StateObject private var connectionManager = ConnectionManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(connectionManager)
                .onAppear {
                    // 延迟设置窗口标题，确保窗口已创建
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NSApplication.shared.windows.forEach { window in
                            window.title = "NavicatMac"
                        }
                    }
                }
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