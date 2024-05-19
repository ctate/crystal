import SwiftUI

struct VoiceModelsView: View {
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
        Provider(name: "Apple", models: [
            Model(id: "default", name: "Default", hasVision: false)
        ]),
        Provider(name: "OpenAI", models: [
            Model(id: "whisper", name: "Whisper", hasVision: false)
        ]),
    ]
    
    @State private var selectedModelId: String = UserDefaults.standard.string(forKey: "defaultVoiceModel") ?? ""
    
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
                            UserDefaults.standard.setValue(model.id, forKey: "defaultVoiceModel")
                            selectedModelId = model.id
                        }
                    }
                }
            }
        }
        .navigationTitle("Voice Model")
    }
}

#Preview {
    VoiceModelsView()
}
