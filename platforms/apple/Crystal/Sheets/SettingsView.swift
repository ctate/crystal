import KeychainAccess
import SwiftUI

struct Integration: Identifiable {
    let id: String
    var name: String
    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "\(id):isEnabled")
        }
    }
    var hasApiKey: Bool
    var apiKey: String {
        didSet {
            if let data = apiKey.data(using: .utf8) {
                _ = save(key: "\(bundleIdentifier).\(id)ApiKey", data: data)
            }
        }
    }
    
    init(id: String, name: String, isEnabled: Bool = false, hasApiKey: Bool = false) {
        self.id = id
        self.name = name
        self.isEnabled = UserDefaults.standard.bool(forKey: "\(id):isEnabled")
        self.hasApiKey = hasApiKey
        self.apiKey = loadApiKey(key: "\(bundleIdentifier).\(name)ApiKey")
    }
    
    var displayApiKey: String {
        guard apiKey.count > 8 else { return apiKey }
        let prefix = apiKey.prefix(4)
        let suffix = apiKey.suffix(4)
        return "\(prefix)...\(suffix)"
    }
    
    mutating func clearApiKey() {
        apiKey = ""
        _ = delete(key: "\(bundleIdentifier).\(name)ApiKey")
    }
}

struct ProviderWithSettings: Identifiable {
    let id: String
    var name: String
    var isService: Bool
    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "\(id):isEnabled")
        }
    }
    var apiKey: String {
        didSet {
            if let data = apiKey.data(using: .utf8) {
                _ = save(key: "\(bundleIdentifier).\(id)ApiKey", data: data)
            }
        }
    }
    var host: String {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "\(id):host")
        }
    }
    
    init(id: String, name: String, isEnabled: Bool = false, isService: Bool = false) {
        self.id = id
        self.name = name
        self.isEnabled = UserDefaults.standard.bool(forKey: "\(id):isEnabled")
        self.isService = isService
        self.apiKey = loadApiKey(key: "\(bundleIdentifier).\(name)ApiKey")
        self.host = UserDefaults.standard.string(forKey: "\(id):host") ?? ""
    }
    
    var displayApiKey: String {
        guard apiKey.count > 8 else { return apiKey }
        let prefix = apiKey.prefix(4)
        let suffix = apiKey.suffix(4)
        return "\(prefix)...\(suffix)"
    }
    
    mutating func clearApiKey() {
        apiKey = ""
        _ = delete(key: "\(bundleIdentifier).\(name)ApiKey")
    }
}

func loadApiKey(key: String) -> String {
    guard let apiKeyData = load(key: key) else { return "" }
    return String(decoding: apiKeyData, as: UTF8.self)
}

struct IntegrationDetailView: View {
    @Binding var integration: Integration
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Toggle("Enabled", isOn: $integration.isEnabled)
                .onChange(of: integration.isEnabled) {
                    UserDefaults.standard.set(integration.isEnabled, forKey: "\(integration.id):isEnabled")
                }
            HStack {
                TextField("API Key", text: $integration.apiKey)
                    .disabled(!integration.apiKey.isEmpty)
                    .onChange(of: integration.apiKey) {
                        // Save the new value to the Keychain
                        if let data = integration.apiKey.data(using: .utf8) {
                            _ = save(key: "\(bundleIdentifier).\(integration.id)ApiKey", data: data)
                        }
                    }
                
                if !integration.apiKey.isEmpty {
                    Spacer()
                    Button(action: {
                        showAlert = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .alert("Are you sure you want to clear the API key?", isPresented: $showAlert) {
                        Button("Clear", role: .destructive) {
                            integration.clearApiKey()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
        .navigationTitle(integration.name)
        .padding()
    }
}

struct ProviderDetailView: View {
    @Binding var provider: ProviderWithSettings
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Toggle("Enabled", isOn: $provider.isEnabled)
                .onChange(of: provider.isEnabled) {
                    UserDefaults.standard.set(provider.isEnabled, forKey: "\(provider.id):isEnabled")
                }
            HStack {
                if provider.isService {
                    SecureField("API Key", text: $provider.apiKey)
                        .disabled(!provider.apiKey.isEmpty)
                        .onChange(of: provider.apiKey) {
                            if let data = provider.apiKey.data(using: .utf8) {
                                _ = save(key: "\(bundleIdentifier).\(provider.id)ApiKey", data: data)
                            }
                        }
                } else {
                    TextField("Host", text: $provider.host)
                        .disabled(!provider.apiKey.isEmpty)
                        .onChange(of: provider.host) {
                            UserDefaults.standard.set(provider.host, forKey: "\(provider.id):host")
                        }
                }
                
                if !provider.apiKey.isEmpty {
                    Spacer()
                    Button(action: {
                        showAlert = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .alert("Are you sure you want to clear the API key?", isPresented: $showAlert) {
                        Button("Clear", role: .destructive) {
                            provider.clearApiKey()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
        .navigationTitle(provider.name)
        .padding()
    }
}

struct GeneralSettingsView: View {
    @State private var darkMode = false
    
    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $darkMode)
        }
    }
}

struct ModelsSettingsView: View {
    @State private var defaults = [
        ProviderWithSettings(id: "Prompt", name: "Prompt", isEnabled: false),
        ProviderWithSettings(id: "Vision", name: "Vision", isEnabled: false),
        ProviderWithSettings(id: "Voice", name: "Voice", isEnabled: false)
    ]
    
    @State private var providers = [
        ProviderWithSettings(id: "OpenAI", name: "OpenAI", isEnabled: false, isService: true),
        ProviderWithSettings(id: "Groq", name: "Groq", isEnabled: false, isService: true),
        ProviderWithSettings(id: "Anthropic", name: "Anthropic", isEnabled: false, isService: true),
        ProviderWithSettings(id: "Ollama", name: "Ollama", isEnabled: false, isService: false)
    ]
    
    private func destinationView(for id: String) -> some View {
        switch id {
        case "Vision":
            return AnyView(VisionModelsView())
        case "Voice":
            return AnyView(VoiceModelsView())
        default:
            return AnyView(PromptModelsView())
        }
    }
    
    private func defaultModel(for id: String) -> String {
        switch id {
        case "Vision":
            return UserDefaults.standard.string(forKey: "defaultVisionModel") ?? ""
        case "Voice":
            return UserDefaults.standard.string(forKey: "defaultVoiceModel") ?? ""
        default:
            return UserDefaults.standard.string(forKey: "defaultPromptModel") ?? ""
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Defaults")) {
                    ForEach($defaults) { $settingsDefault in
                        NavigationLink(destination: destinationView(for: settingsDefault.id)) {
                            HStack {
                                Text(settingsDefault.name)
                                Spacer()
                                Text(defaultModel(for: settingsDefault.id))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("Providers")) {
                    ForEach($providers) { $provider in
                        NavigationLink(destination: ProviderDetailView(provider: $provider)) {
                            HStack {
                                Text(provider.name)
                                Spacer()
                                Text(provider.isEnabled ? "On" : "Off")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct IntegrationsSettingsView: View {
    @State private var integrations = [
        Integration(id: "Google", name: "Google", isEnabled: false, hasApiKey: true),
        Integration(id: "HackerNews", name: "Hacker News", isEnabled: false, hasApiKey: false),
        Integration(id: "WeatherGov", name: "Weather.gov", isEnabled: false, hasApiKey: false),
        Integration(id: "Wikipedia", name: "Wikipedia", isEnabled: false, hasApiKey: false)
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Integrations")) {
                    ForEach($integrations) { $integration in
                        if integration.hasApiKey {
                            NavigationLink(destination: IntegrationDetailView(integration: $integration)) {
                                HStack {
                                    Text(integration.name)
                                    Spacer()
                                    Text(integration.isEnabled ? "On" : "Off")
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                        } else {
                            HStack {
                                Text(integration.name)
                                Spacer()
                                Toggle("", isOn: $integration.isEnabled)
                                    .onChange(of: integration.isEnabled) {
                                        UserDefaults.standard.set(integration.isEnabled, forKey: "\(integration.id):isEnabled")
                                    }
                                
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct DataSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("Delete All Keychain Items") {
                deleteAllKeychainItems()
            }
            
            Button("Delete All Preferences") {
                deleteAllPreferences()
            }
            
            Button("Delete All App Data") {
                deleteAllAppData()
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
    
    func deleteAllKeychainItems() {
        let keychain = Keychain(service: bundleIdentifier)
        do {
            try keychain.removeAll()
            print("All keychain items deleted.")
        } catch {
            print("Failed to delete keychain items: \(error)")
        }
    }
    
    func deleteAllPreferences() {
        UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        UserDefaults.standard.synchronize()
        print("All preferences deleted.")
    }
    
    func deleteAllAppData() {
        let fileManager = FileManager.default
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            for filePath in filePaths {
                try fileManager.removeItem(at: filePath)
            }
            print("All app data deleted.")
        } catch {
            print("Could not clear app data: \(error)")
        }
    }
}

struct SettingsView: View {
#if os(macOS)
    let screenWidth = NSScreen.main?.visibleFrame.width ?? 800
    let screenHeight = NSScreen.main?.visibleFrame.height ?? 600
#endif
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .navigationTitle("General")
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            ModelsSettingsView()
                .navigationTitle("Models")
                .tabItem {
                    Label("Models", systemImage: "diamond")
                }
            
            IntegrationsSettingsView()
                .navigationTitle("Integrations")
                .tabItem {
                    Label("Integrations", systemImage: "glowplug")
                }
            
            DataSettingsView()
                .navigationTitle("Data")
                .tabItem {
                    Label("Data", systemImage: "externaldrive")
                }
        }
#if os(macOS)
        .frame(width: screenWidth/2, height: screenHeight/2)
#endif
    }
}


// Preview for the SwiftUI canvas
#Preview {
    SettingsView()
}