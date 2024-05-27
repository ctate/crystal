import Foundation

struct KeychainKeys {
    struct Integrations {
        struct Google {
            static let apiKey = "\(bundleIdentifier).Integrations.Google.apiKey"
            static let searchEngineId = "\(bundleIdentifier).Integrations.Google.searchEngineId"
        }
    }
    struct Providers {
        struct Anthropic {
            static let apiKey = "\(bundleIdentifier).Providers.Anthropic.apiKey"
        }
        struct Groq {
            static let apiKey = "\(bundleIdentifier).Providers.Groq.apiKey"
        }
        struct Ollama {
            static let apiKey = "\(bundleIdentifier).Providers.Ollama.apiKey"
        }
        struct OpenAI {
            static let apiKey = "\(bundleIdentifier).Providers.OpenAI.apiKey"
        }
    }
}
