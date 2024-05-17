import SwiftUI
import SwiftData

@main
struct CrystalApp: App {
    @Environment(\.openWindow) var openWindow
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Conversation.self,
            Message.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        Window("Crystal", id: "main-window") {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(ConversationManager())
        .modelContainer(sharedModelContainer)
#if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle(showsTitle: false))
#endif
        
        MenuBarExtra("Crystal", systemImage: "diamond") {
            Button("Open Crystal") {
                openWindow(id: "main-window")
                NSApplication.shared.windows.forEach { window in
                    if window.identifier?.rawValue.starts(with: "main-window") ?? false {
                        window.makeKeyAndOrderFront(nil)
                        window.orderFrontRegardless()
                        return
                    }
                }
            }
            
            Divider()
            
            SettingsLink {
                Text("Settings...")
            }
            .keyboardShortcut(",")
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
