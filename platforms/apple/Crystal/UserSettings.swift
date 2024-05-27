import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    var projectedValue: UserDefault<T> {
        return self
    }

    init(_ defaultValue: T, key: String) {
        self.key = key
        self.defaultValue = defaultValue
    }

    func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

@propertyWrapper
struct UserDefaultEnum<T: RawRepresentable> where T.RawValue: Codable {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            if let rawValue = UserDefaults.standard.object(forKey: key) as? T.RawValue,
               let value = T(rawValue: rawValue) {
                return value
            }
            return defaultValue
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
    
    var projectedValue: UserDefaultEnum<T> {
        return self
    }

    init(_ defaultValue: T, key: String) {
        self.key = key
        self.defaultValue = defaultValue
    }

    func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct UserSettings {
    enum Appearance: String {
        case system = "System"
        case dark = "Dark"
        case light = "Light"
    }
    
    @UserDefaultEnum(Appearance.system, key: "appearance")
    static var appearance: Appearance
    
    @UserDefault("System", key: "font")
    static var font: String
    
    @UserDefault(false, key: "functionsDisabled")
    static var functionsDisabled: Bool
    
    @UserDefault(false, key: "hasCompletedOnboarding")
    static var hasCompletedOnboarding: Bool
    
    @UserDefault(false, key: "isMuted")
    static var isMuted: Bool
    
    @UserDefault(nil, key: "promptModel")
    static var promptModel: String?
    
    @UserDefault(nil, key: "promptProvider")
    static var promptProvider: String?
    
    @UserDefault(nil, key: "visionModel")
    static var visionModel: String?
    
    @UserDefault(nil, key: "visionProvider")
    static var visionProvider: String?
    
    @UserDefault(nil, key: "voiceModel")
    static var voiceModel: String?
    
    @UserDefault(nil, key: "voiceProvider")
    static var voiceProvider: String?

    struct Providers {
        struct Anthropic {
            @UserDefault(false, key: "Providers:Anthropic:isEnabled")
            static var isEnabled: Bool
        }

        struct Groq {
            @UserDefault(false, key: "Providers:Groq:isEnabled")
            static var isEnabled: Bool
        }

        struct Ollama {
            @UserDefault(false, key: "Providers:Ollama:isEnabled")
            static var isEnabled: Bool

            @UserDefault(nil, key: "Providers:Ollama:host")
            static var host: String?
        }

        struct OpenAI {
            @UserDefault(false, key: "Providers:OpenAI:isEnabled")
            static var isEnabled: Bool
        }
        
        private static let hostMapping: [String: String] = [
            "Ollama": "Providers:Ollama:host"
        ]
        
        static func host(_ name: String) -> String? {
            guard let key = hostMapping[name] else {
                return nil
            }
            return UserDefaults.standard.string(forKey: key)
        }
        
        static func setHost(_ name: String, host: String?) {
            guard let key = hostMapping[name] else {
                return
            }
            UserDefaults.standard.set(host, forKey: key)
        }
        
        private static let isEnabledMapping: [String: String] = [
            "Anthropic": "Providers:Anthropic:isEnabled",
            "Groq": "Providers:Groq:isEnabled",
            "Ollama": "Providers:Ollama:isEnabled",
            "OpenAI": "Providers:OpenAI:isEnabled"
        ]
        
        static func isEnabled(_ name: String) -> Bool {
            guard let key = isEnabledMapping[name] else {
                return false
            }
            return UserDefaults.standard.bool(forKey: key)
        }
        
        static func setIsEnabled(_ name: String, isEnabled: Bool) {
            guard let key = isEnabledMapping[name] else {
                return
            }
            UserDefaults.standard.set(isEnabled, forKey: key)
        }
    }

    struct Integrations {
        struct Google {
            @UserDefault(false, key: "Integrations:Google:isEnabled")
            static var isEnabled: Bool
        }

        struct HackerNews {
            @UserDefault(false, key: "Integrations:HackerNews:isEnabled")
            static var isEnabled: Bool
        }

        struct WeatherGov {
            @UserDefault(false, key: "Integrations:WeatherGov:isEnabled")
            static var isEnabled: Bool
        }

        struct Wikipedia {
            @UserDefault(false, key: "Integrations:Wikipedia:isEnabled")
            static var isEnabled: Bool
        }
        
        private static let isEnabledMapping: [String: String] = [
            "Google": "Integrations:Google:isEnabled",
            "HackerNews": "Integrations:HackerNews:isEnabled",
            "WeatherGov": "Integrations:WeatherGov:isEnabled",
            "Wikipedia": "Integrations:Wikipedia:isEnabled",
        ]
        
        static func isEnabled(_ name: String) -> Bool {
            guard let key = isEnabledMapping[name] else {
                return false
            }
            return UserDefaults.standard.bool(forKey: key)
        }
        
        static func setIsEnabled(_ name: String, isEnabled: Bool) {
            guard let key = isEnabledMapping[name] else {
                return
            }
            UserDefaults.standard.set(isEnabled, forKey: key)
        }
    }
}
