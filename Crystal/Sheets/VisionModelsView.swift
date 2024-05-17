import SwiftUI

struct VisionModelsView: View {
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
            Model(id: "gpt-4-turbo", name: "GPT-4 Turbo", hasVision: true),
            Model(id: "gpt-4", name: "GPT-4", hasVision: true)
        ]),
        Provider(name: "Anthropic", models: [
            Model(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", hasVision: true),
            Model(id: "claude-3-sonnet-20240229", name: "Claude 3 Sonnet", hasVision: true),
            Model(id: "claude-3-opus-20240229", name: "Claude 3 Opus", hasVision: true)
        ])
    ]
    
    @State private var selectedModelId: String = UserDefaults.standard.string(forKey: "defaultVisionModel") ?? ""
    
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
                            UserDefaults.standard.setValue(model.id, forKey: "defaultVisionModel")
                            selectedModelId = model.id
                        }
                    }
                }
            }
        }
        .navigationTitle("Vision Model")
    }
}

#Preview {
    VisionModelsView()
}
