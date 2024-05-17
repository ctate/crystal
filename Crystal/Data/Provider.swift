import Foundation

struct ProviderModel: Hashable, Identifiable {
    let id: String
    let name: String
    let hasVision: Bool
}

struct Provider: Hashable, Identifiable {
    let id: String
    let name: String
    let image: String
    let models: [ProviderModel]
}

let providers = [
    Provider(id: "OpenAI", name: "OpenAI", image: "OpenAILogo", models: [
        ProviderModel(id: "gpt-3.5-turbo", name: "GPT-3.5 Turbo", hasVision: false),
        ProviderModel(id: "gpt-4o", name: "GPT-4o", hasVision: true),
        ProviderModel(id: "gpt-4-turbo", name: "GPT-4 Turbo", hasVision: true),
        ProviderModel(id: "gpt-4", name: "GPT-4", hasVision: true)
    ]),
    Provider(id: "Groq", name: "Groq", image: "GroqLogo", models: [
        ProviderModel(id: "llama3-8b-8192", name: "Llama 3 8B", hasVision: false),
        ProviderModel(id: "llama3-70b-8192", name: "Llama 3 70B", hasVision: false),
        ProviderModel(id: "gemma-7b-it", name: "Gemma 7B", hasVision: false),
        ProviderModel(id: "mixtral-8x7b-32768", name: "Mixtral 8x7B SMoE", hasVision: false)
    ]),
    Provider(id: "Anthropic", name: "Anthropic", image: "AnthropicLogo", models: [
        ProviderModel(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", hasVision: true),
        ProviderModel(id: "claude-3-sonnet-20240229", name: "Claude 3 Sonnet", hasVision: true),
        ProviderModel(id: "claude-3-opus-20240229", name: "Claude 3 Opus", hasVision: true)
    ])
]

func findProviderById(_ id: String) -> Provider? {
    for provider in providers {
        if provider.id == id {
            return provider
        }
    }
    return nil
}

func findProviderByModelId(_ modelId: String) -> Provider? {
    for provider in providers {
        for model in provider.models {
            if model.id == modelId {
                return provider
            }
        }
    }
    return nil
}
