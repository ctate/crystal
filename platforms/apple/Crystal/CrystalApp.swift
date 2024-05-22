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
#if os(macOS)
        Window("Crystal", id: "main-window") {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(ConversationManager())
        .modelContainer(sharedModelContainer)
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle(showsTitle: false))
#else
        WindowGroup("Crystal", id: "main-window") {
            ContentView()
                .environment(\.font, Font.custom(UserDefaults.standard.string(forKey: UserDefaults.Keys.font) ?? "San Francisco", size: 14))
//                .forceDarkMode()
//                .preferredColorScheme(.dark)
        }
        .environmentObject(ConversationManager())
        .modelContainer(sharedModelContainer)
#endif

#if os(macOS)
        MenuBarExtra("Crystal", image: "MenuBarIcon") {
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
#endif
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
