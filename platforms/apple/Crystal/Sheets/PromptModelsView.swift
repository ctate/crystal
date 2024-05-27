import SwiftUI

struct PromptModelsView: View {
    struct Model: Identifiable {
        let id: String
        let name: String
        let hasVision: Bool
    }
    
    struct Provider: Identifiable {
        let id = UUID()
        let name: String
        let models: [Model]
    }
    
    @State private var providers: [Provider] = [
        Provider(name: "OpenAI", models: [
            Model(id: "gpt-3.5-turbo", name: "GPT-3.5 Turbo", hasVision: false),
            Model(id: "gpt-4o", name: "GPT-4o", hasVision: true),
            Model(id: "gpt-4-turbo", name: "GPT-4 Turbo", hasVision: true),
            Model(id: "gpt-4", name: "GPT-4", hasVision: true)
        ]),
        Provider(name: "Groq", models: [
            Model(id: "llama3-8b-8192", name: "Llama 3 8B", hasVision: false),
            Model(id: "llama3-70b-8192", name: "Llama 3 70B", hasVision: false),
            Model(id: "gemma-7b-it", name: "Gemma 7B", hasVision: false),
            Model(id: "mixtral-8x7b-32768", name: "Mixtral 8x7B SMoE", hasVision: false)
        ]),
        Provider(name: "Anthropic", models: [
            Model(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", hasVision: true),
            Model(id: "claude-3-sonnet-20240229", name: "Claude 3 Sonnet", hasVision: true),
            Model(id: "claude-3-opus-20240229", name: "Claude 3 Opus", hasVision: true)
        ])
    ]
    
    @State private var selectedModelId: String = UserSettings.promptModel ?? ""
    
    var body: some View {
        List {
            ForEach(providers) { provider in
                Section(header: Text(provider.name)) {
                    ForEach(provider.models) { model in
                        HStack {
                            Text(model.name)
                            Spacer()
                            if selectedModelId == model.id {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UserSettings.promptProvider = provider.name
                            UserSettings.promptModel = model.id
                            selectedModelId = model.id
                        }
                    }
                }
            }
        }
        .navigationTitle("Prompt Model")
    }
}

#Preview {
    PromptModelsView()
}
