import KeychainAccess
import SwiftUI

struct Integration: Identifiable {
    let id: String
    var name: String
    var isEnabled: Bool {
        didSet {
            UserSettings.Integrations.setIsEnabled(id, isEnabled: isEnabled)
        }
    }
    var hasApiKey: Bool
    var apiKey: String {
        didSet {
            if let data = apiKey.data(using: .utf8) {
                switch id {
                case "Anthropic":
                    _ = save(KeychainKeys.Providers.Anthropic.apiKey, data: data)
                case "Groq":
                    _ = save(KeychainKeys.Providers.Groq.apiKey, data: data)
                case "Ollama":
                    _ = save(KeychainKeys.Providers.Ollama.apiKey, data: data)
                case "OpenAI":
                    _ = save(KeychainKeys.Providers.OpenAI.apiKey, data: data)
                default:
                    print("Unknown id")
                }
            }
        }
    }
    
    init(id: String, name: String, hasApiKey: Bool = false) {
        self.id = id
        self.name = name
        self.isEnabled = UserSettings.Integrations.isEnabled(id)
        self.hasApiKey = hasApiKey
        self.apiKey = loadApiKey(key: id)
    }
    
    var displayApiKey: String {
        guard apiKey.count > 8 else { return apiKey }
        let prefix = apiKey.prefix(4)
        let suffix = apiKey.suffix(4)
        return "\(prefix)...\(suffix)"
    }
    
    mutating func clearApiKey() {
        apiKey = ""
        switch name {
        case "Anthropic":
            _ = delete(KeychainKeys.Providers.Anthropic.apiKey)
        case "Groq":
            _ = delete(KeychainKeys.Providers.Groq.apiKey)
        case "Ollama":
            _ = delete(KeychainKeys.Providers.Ollama.apiKey)
        case "OpenAI":
            _ = delete(KeychainKeys.Providers.OpenAI.apiKey)
        default:
            print("Unknown id")
        }
    }
}

struct ProviderWithSettings: Identifiable {
    let id: String
    var name: String
    var isService: Bool
    var isEnabled: Bool {
        didSet {
            UserSettings.Providers.setIsEnabled(id, isEnabled: isEnabled)
        }
    }
    var apiKey: String {
        didSet {
            if let data = apiKey.data(using: .utf8) {
                switch id {
                case "Anthropic":
                    _ = save(KeychainKeys.Providers.Anthropic.apiKey, data: data)
                case "Groq":
                    _ = save(KeychainKeys.Providers.Groq.apiKey, data: data)
                case "Ollama":
                    _ = save(KeychainKeys.Providers.Ollama.apiKey, data: data)
                case "OpenAI":
                    _ = save(KeychainKeys.Providers.OpenAI.apiKey, data: data)
                default:
                    print("Unknown id")
                }
            }
        }
    }
    var host: String {
        didSet {
            UserSettings.Providers.setHost(id, host: host)
        }
    }
    
    init(id: String, name: String, isService: Bool = false) {
        self.id = id
        self.name = name
        self.isEnabled = UserSettings.Providers.isEnabled(id)
        self.isService = isService
        self.apiKey = loadApiKey(key: id)
        self.host = UserSettings.Providers.host(id) ?? ""
    }
    
    var displayApiKey: String {
        guard apiKey.count > 8 else { return apiKey }
        let prefix = apiKey.prefix(4)
        let suffix = apiKey.suffix(4)
        return "\(prefix)...\(suffix)"
    }
    
    mutating func clearApiKey() {
        apiKey = ""
        switch name {
        case "Anthropic":
            _ = delete(KeychainKeys.Providers.Anthropic.apiKey)
        case "Groq":
            _ = delete(KeychainKeys.Providers.Groq.apiKey)
        case "Ollama":
            _ = delete(KeychainKeys.Providers.Ollama.apiKey)
        case "OpenAI":
            _ = delete(KeychainKeys.Providers.OpenAI.apiKey)
        default:
            print("Unknown id")
        }
    }
}

func loadApiKey(key: String) -> String {
    let keyMap = [
        "Anthropic": KeychainKeys.Providers.Anthropic.apiKey,
        "Groq": KeychainKeys.Providers.Groq.apiKey,
        "Ollama": KeychainKeys.Providers.Ollama.apiKey,
        "OpenAI": KeychainKeys.Providers.OpenAI.apiKey
    ]
    
    guard let key = keyMap[key], let apiKeyData = load(key) else {
        return ""
    }
    
    return String(decoding: apiKeyData, as: UTF8.self)
}

struct IntegrationDetailView: View {
    @Binding var integration: Integration
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Toggle("Enabled", isOn: $integration.isEnabled)
                .onChange(of: integration.isEnabled) {
                    UserSettings.Integrations.setIsEnabled(integration.id, isEnabled: integration.isEnabled)
                }
            HStack {
                TextField("API Key", text: $integration.apiKey)
                    .disabled(!integration.apiKey.isEmpty)
                    .onChange(of: integration.apiKey) {
                        // Save the new value to the Keychain
                        if let data = integration.apiKey.data(using: .utf8) {
                            switch integration.id {
                            case "Google":
                                _ = save(KeychainKeys.Integrations.Google.apiKey, data: data)
                            default:
                                print("Unknown integration")
                            }
                            
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
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

struct ProviderDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var provider: ProviderWithSettings
    @State private var showAlert = false
    
    @State private var apiKey = ""
    @State private var host = ""
    @State private var isEnabled = false

    var body: some View {
        Form {
            Toggle("Enabled", isOn: $isEnabled)
                .onChange(of: isEnabled) {
                    UserSettings.Providers.setIsEnabled(provider.id, isEnabled: isEnabled)
                    
                    provider.isEnabled = isEnabled
                }
            HStack {
                if provider.isService {
                    SecureField("API Key", text: $apiKey)
                        .disabled(!provider.apiKey.isEmpty)
                } else {
                    TextField("Host", text: $host)
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
                            apiKey = ""
                            provider.clearApiKey()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            Button(action: {
                if let data = apiKey.data(using: .utf8) {
                    switch provider.id {
                    case "Anthropic":
                        _ = save(KeychainKeys.Providers.Anthropic.apiKey, data: data)
                    case "Groq":
                        _ = save(KeychainKeys.Providers.Groq.apiKey, data: data)
                    case "Ollama":
                        _ = save(KeychainKeys.Providers.Ollama.apiKey, data: data)
                    case "OpenAI":
                        _ = save(KeychainKeys.Providers.OpenAI.apiKey, data: data)
                    default:
                        print("Unknown id")
                    }
                }
            }) {
                Text("Save")
            }
        }
        .padding()
        .navigationTitle(provider.name)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            self.apiKey = provider.apiKey
            self.host = provider.host
            self.isEnabled = provider.isEnabled
        }
    }
}

struct GeneralSettingsView: View {
    @State private var isMuted = UserSettings.isMuted
    
    @State private var selectedAppearance = UserSettings.appearance
    let appearanceOptions = [UserSettings.Appearance.system, UserSettings.Appearance.dark, UserSettings.Appearance.light]
    
    @State private var selectedFont = UserSettings.font
    let fonts = [
        "San Francisco (Default)",
        "Arial",
        "Helvetica",
        "Times New Roman",
        "Courier",
        "Verdana",
        "Trebuchet MS",
        "Georgia",
        "Palatino",
        "Gill Sans",
        "Futura",
        "Optima"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Appearance", selection: $selectedAppearance) {
                    ForEach(appearanceOptions, id: \.self) { appearance in
                        Text(appearance.rawValue)
                    }
                }
                .onChange(of: selectedAppearance) {
                    UserSettings.appearance = selectedAppearance
                }
                
                Picker("Primary Font", selection: $selectedFont) {
                    ForEach(fonts, id: \.self) { font in
                        Text(font).font(Font.custom(font, size: 18))
                    }
                }
                .onChange(of: selectedFont) {
                    UserSettings.font = selectedFont
                }
                
                Toggle("Mute", isOn: $isMuted)
                    .onChange(of: isMuted) {
                        UserSettings.isMuted = isMuted
                    }
            }
            .navigationTitle("General")
        }
    }
}

struct ModelsSettingsView: View {
    @State private var defaults = [
        ProviderWithSettings(id: "Prompt", name: "Prompt"),
        ProviderWithSettings(id: "Vision", name: "Vision"),
        ProviderWithSettings(id: "Voice", name: "Voice")
    ]
    
    @State private var providers = [
        ProviderWithSettings(id: "OpenAI", name: "OpenAI", isService: true),
        ProviderWithSettings(id: "Groq", name: "Groq", isService: true),
        ProviderWithSettings(id: "Anthropic", name: "Anthropic", isService: true),
        ProviderWithSettings(id: "Ollama", name: "Ollama", isService: false)
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
            return UserSettings.visionModel ?? ""
        case "Voice":
            return UserSettings.voiceModel ?? ""
        default:
            return UserSettings.promptModel ?? ""
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
        Integration(
            id: "Google",
            name: "Google",
            hasApiKey: true
        ),
        Integration(
            id: "HackerNews",
            name: "Hacker News",
            hasApiKey: false
        ),
        Integration(
            id: "WeatherGov",
            name: "Weather.gov",
            hasApiKey: false
        ),
        Integration(
            id: "Wikipedia",
            name: "Wikipedia",
            hasApiKey: false
        )
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
                                        UserSettings.Integrations.setIsEnabled(integration.id, isEnabled: integration.isEnabled)
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
    @State var selectedTab: String
    
#if os(macOS)
    let screenWidth = NSScreen.main?.visibleFrame.width ?? 800
    let screenHeight = NSScreen.main?.visibleFrame.height ?? 600
#endif
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag("general")
            
            ModelsSettingsView()
                .tabItem {
                    Label("Models", systemImage: "diamond")
                }
                .tag("models")
            
            IntegrationsSettingsView()
                .tabItem {
                    Label("Integrations", systemImage: "glowplug")
                }
                .tag("integrations")
            
            DataSettingsView()
                .tabItem {
                    Label("Data", systemImage: "externaldrive")
                }
                .tag("data")
        }
#if os(macOS)
        .frame(width: screenWidth/2, height: screenHeight/2)
#endif
    }
}


// Preview for the SwiftUI canvas
#Preview {
    SettingsView(selectedTab: "general")
}
