import SwiftUI

#if os(iOS)
struct WelcomeView: View {
    enum Step {
        case welcome
        case selectProvider
        case inputDetails
    }
    
    @State private var currentStep = Step.welcome
    @State private var fadeIn = false
    @State private var selectedProvider: Provider?
    @State private var model = ""
    @State private var apiKey = ""
    
    @State private var isKeyValidated: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                if currentStep != .welcome {
                    Button(action: goBack) {
                        Label("Back", systemImage: "arrow.left")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                
                
                if currentStep == .welcome {
                    welcomeView
                } else if currentStep == .selectProvider {
                    providerSelectionView
                } else if currentStep == .inputDetails {
                    inputDetailsView
                }
            }
            .navigationDestination(isPresented: $isKeyValidated) {
                ChatView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // Welcome View content
    var welcomeView: some View {
        VStack(spacing: 20) {
            Text("Welcome to Crystal")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(fadeIn ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5), value: fadeIn)
            
            Text("Your personal AI assistant")
                .font(.title)
                .foregroundColor(.white)
                .opacity(fadeIn ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5).delay(0.5), value: fadeIn)
            
            Button("Next") {
                withAnimation {
                    switch currentStep {
                    case .welcome:
                        currentStep = .selectProvider
                    case .selectProvider:
                        currentStep = .inputDetails
                    case .inputDetails:
                        break
                    }
                }
            }
            .padding(10)
            .background(.black)
            .cornerRadius(40)
            .buttonStyle(.bordered)
            .foregroundColor(.white)
            .padding()
            .opacity(fadeIn ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5).delay(1), value: fadeIn)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                fadeIn = true
            }
        }
    }
    
    // Provider selection content
    var providerSelectionView: some View {
        VStack {
            Text("Select an AI Provider")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            ForEach(providers, id: \.self) { provider in
                Button(action: {
                    selectedProvider = provider
                    model = provider.models.first!.id
                    
                    withAnimation {
                        currentStep = .inputDetails
                    }
                }) {
                    Image(provider.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text(provider.name)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                .foregroundColor(.primary)
                .frame(maxWidth: 200, alignment: .leading)
            }
        }
    }
    
    // Input details content
    var inputDetailsView: some View {
        VStack {
            Text(selectedProvider?.name ?? "")
                .font(.title)
                .fontWeight(.bold)
            Form {
                Picker("Model", selection: $model) {
                    ForEach(selectedProvider?.models ?? [], id: \.self) { model in
                        Text(model.name).tag(model.id)
                    }
                }
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            .padding(.horizontal)
            .frame(maxWidth: 400)
            Button("Next") {
                UserDefaults.standard.setValue(selectedProvider!.id, forKey: "defaultPromptProvider")
                UserDefaults.standard.setValue(model, forKey: "defaultPromptModel")
                UserDefaults.standard.setValue(true, forKey: "hasCompletedOnboarding")
                
                let data = apiKey.data(using: .utf8)!
                _ = save(key: "\(bundleIdentifier).\(selectedProvider!.id)ApiKey", data: data)
                
                isKeyValidated = true
            }
            .background(.black)
            .cornerRadius(5)
            .buttonStyle(.bordered)
            .foregroundColor(.white)
            .padding()
            .opacity(fadeIn ? 1.0 : 0.0)
            .animation(.easeIn(duration: 1.5).delay(1), value: fadeIn)
        }
    }
    
    // Function to handle back navigation
    func goBack() {
        withAnimation {
            switch currentStep {
            case .selectProvider:
                currentStep = .welcome
            case .inputDetails:
                currentStep = .selectProvider
            default:
                break
            }
        }
    }
}
#endif

#if os(macOS)
struct WelcomeView: View {
    enum Step {
        case welcome
        case selectProvider
        case inputDetails
    }
    
    @State private var currentStep = Step.welcome
    @State private var fadeIn = false
    @State private var selectedProvider: Provider?
    @State private var model = ""
    @State private var apiKey = ""
    
    @State private var isKeyValidated: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            NavigationStack {
                VStack {
                    ZStack {
                        if currentStep != .welcome {
                            Button(action: goBack) {
                                Label("Back", systemImage: "arrow.left")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        
                        if currentStep == .welcome {
                            welcomeView
                        } else if currentStep == .selectProvider {
                            providerSelectionView
                        } else if currentStep == .inputDetails {
                            inputDetailsView
                        }
                    }
                    .transition(.opacity)
                }.navigationDestination(isPresented: $isKeyValidated) {
                    ChatView()
                        .navigationBarBackButtonHidden(true)
                }}
        }
    }
    
    // Welcome View content
    var welcomeView: some View {
        VStack(spacing: 20) {
            Text("Welcome to Crystal")
                .font(.largeTitle)
                .fontWeight(.bold)
                .opacity(fadeIn ? 1.0 : 0.0)
                .animation(.easeIn(duration: 1.5), value: fadeIn)
            
            Text("Your personal AI assistant")
                .font(.title)
                .opacity(fadeIn ? 1.0 : 0.0)
                .animation(.easeIn(duration: 1.5).delay(0.5), value: fadeIn)
            
            Button("Next") {
                withAnimation {
                    switch currentStep {
                    case .welcome:
                        currentStep = .selectProvider
                    case .selectProvider:
                        currentStep = .inputDetails
                    case .inputDetails:
                        break
                    }
                }
            }
            .background(.black)
            .cornerRadius(5)
            .buttonStyle(.bordered)
            .foregroundColor(.white)
            .padding()
            .opacity(fadeIn ? 1.0 : 0.0)
            .animation(.easeIn(duration: 1.5).delay(1), value: fadeIn)
        }
        .onAppear {
            fadeIn = true
        }
    }
    
    // Provider selection content
    var providerSelectionView: some View {
        VStack {
            Text("Select an AI Provider")
                .font(.title)
                .fontWeight(.bold)
            ForEach(providers, id: \.self) { provider in
                Button(action: {
                    selectedProvider = provider
                    withAnimation {
                        currentStep = .inputDetails
                    }
                }) {
                    Image(provider.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text(provider.name)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: 200, alignment: .leading)
            }
        }
    }
    
    // Input details content
    var inputDetailsView: some View {
        VStack {
            Text(selectedProvider?.name ?? "")
                .font(.title)
                .fontWeight(.bold)
            Form {
                Picker("Model", selection: $model) {
                    ForEach(selectedProvider?.models ?? [], id: \.self) { model in
                        Text(model.name).tag(model.id)
                    }
                }
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            .padding(.horizontal)
            .frame(maxWidth: 400)
            Button("Next") {
                UserDefaults.standard.setValue(selectedProvider!.id, forKey: "defaultPromptProvider")
                UserDefaults.standard.setValue(model, forKey: "defaultPromptModel")
                UserDefaults.standard.setValue(true, forKey: "hasCompletedOnboarding")
                
                let data = apiKey.data(using: .utf8)!
                _ = save(key: "\(bundleIdentifier).\(selectedProvider!.id)ApiKey", data: data)
                
                isKeyValidated = true
            }
            .background(.black)
            .cornerRadius(5)
            .buttonStyle(.bordered)
            .foregroundColor(.white)
            .padding()
            .opacity(fadeIn ? 1.0 : 0.0)
            .animation(.easeIn(duration: 1.5).delay(1), value: fadeIn)
        }
    }
    
    // Function to handle back navigation
    func goBack() {
        withAnimation {
            switch currentStep {
            case .selectProvider:
                currentStep = .welcome
            case .inputDetails:
                currentStep = .selectProvider
            default:
                break
            }
        }
    }
}
#endif

#Preview {
    WelcomeView()
}

