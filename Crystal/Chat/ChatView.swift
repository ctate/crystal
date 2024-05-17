import SwiftUI
import SwiftData

struct ChatContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var conversationManager: ConversationManager
    
    var sidebarAction: (() -> Void)? = {}
    @Query private var messages: [Message]
    
#if os(iOS)
    @State private var image: UIImage?
#endif
#if os(macOS)
    @State private var image: NSImage?
#endif
    @StateObject var viewModel = ChatViewModel()
    @State private var messageText: String = ""
    @State private var animate = false
    @ObservedObject var speechRecognizer = SpeechRecognizerService()
    @State private var isSheetPresented = false
    @State var presentSheet = ""
    @State private var showPopover = false
    @State private var showRecorder = false
    @State private var textHeight: CGFloat = 30
    @State private var userInput: String = ""
    
    var body: some View {
        VStack {
            if speechRecognizer.isRecording || viewModel.isLoading {
                Text(viewModel.prompt)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .italic()
                    .font(.title).padding(.horizontal, 20).foregroundColor(.gray)
            } else {
                viewModel.currentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            
            HStack(alignment: .bottom) {
                VStack {
                    Button(action: {
                        presentSheet = "camera"
                    }) {
                        Image(systemName: "camera")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                if showRecorder {
                    OrbButton(animate: $animate)
                        .onTapGesture {
                            do {
                                if speechRecognizer.isRecording {
                                    self.animate = false
                                    speechRecognizer.stopRecording()
                                    
                                    viewModel.sendMessage(
                                        speechRecognizer.recognizedText,
                                        conversationManager: conversationManager,
                                        modelContext: modelContext
                                    )
                                    
                                    messageText = ""
                                } else {
                                    self.animate = true
                                    speechRecognizer.recognizedText = ""
                                    try speechRecognizer.startRecording()
                                }
                            } catch {
                                print("Failed to start recording: \(error)")
                            }
                        }
                        .padding(.bottom, 40)
                } else {
                    VStack(alignment: .trailing) {
                        CustomTextEditor(text: $userInput)
                    }
                }
                
                Spacer()
                
#if os(iOS)
                Menu {
                    Button(action: { presentSheet = "image" }) {
                        Label("Select Image", systemImage: "photo")
                    }
                    Button(action: { presentSheet = "document" }) {
                        Label("Select File", systemImage: "folder")
                    }
                } label: {
                    Image(systemName: "paperclip")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 36)
#endif
                
#if os(macOS)
                Button(action: {
                    viewModel.sendMessage(
                        userInput,
                        conversationManager: conversationManager,
                        modelContext: modelContext
                    )
                    userInput = ""
                }) {
                    Image(systemName: "arrow.up")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $showPopover, arrowEdge: .trailing) {
                    VStack {
                        Button(action: { presentSheet = "image" }) {
                            Label("Select Image", systemImage: "photo")
                        }
                        Button(action: { presentSheet = "document" }) {
                            Label("Select File", systemImage: "folder")
                        }
                    }
                    .frame(width: 200, height: 100)
                    .padding()
                }
                .keyboardShortcut(.return, modifiers: [.command])
#endif
            }
            .padding()
            
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.darkBlue, Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .ignoresSafeArea(edges: .all)
        .onChange(of: presentSheet) {
            if (presentSheet.isEmpty) {
                isSheetPresented = false
            } else {
                isSheetPresented = true
            }
        }
        .sheet(isPresented: $isSheetPresented, onDismiss: {
            presentSheet = ""
        }, content: {
            switch presentSheet {
#if os(iOS)
            case "camera":
                CameraView(image: $image)
            case "document":
                DocumentPicker()
            case "image":
                ImagePicker(image: nil)
#endif
            case "history":
#if os(macOS)
                let screenWidth = NSScreen.main?.visibleFrame.width ?? 800
                let screenHeight = NSScreen.main?.visibleFrame.height ?? 600
                ChatHistoryView()
                    .frame(width: screenWidth/2, height: screenHeight/2)
#else
                ChatHistoryView()
#endif
            case "settings":
                SettingsView()
            default:
                Text("No sheet")
            }
        })
        .onChange(of: conversationManager.selectedConversation, {
            if conversationManager.selectedConversation != nil {
                viewModel.updateViewBasedOnLastMessage(modelContext, conversation: conversationManager.selectedConversation!)
            }
        })
        .toolbar {
            ChatToolbarView(sidebarAction: {
                if sidebarAction != nil {
                    sidebarAction!()
                }
            }, historyAction: {
                presentSheet = "history"
            }, settingsAction: {
                presentSheet = "settings"
            }, newAction: {
                viewModel.currentView = AnyView(TextCard(text: "How can I help?"))
                conversationManager.selectedConversation = nil
            })
        }
    }
}

struct ChatView: View {
#if os(iOS)
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
#endif
    
    @State private var isSidebarVisible: Bool = false
    private let sidebarWidth: CGFloat = 300
    
    var body: some View {
#if os(macOS)
        HStack(spacing: 0) {
            if isSidebarVisible {
                SidebarView()
                    .frame(width: sidebarWidth)
                    .transition(.move(edge: .leading))
            }
            
            ChatContentView(sidebarAction: {
                withAnimation {
                    isSidebarVisible.toggle()
                }
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
#else
        NavigationView {
            ChatContentView()
        }
#endif
    }
}

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var conversationManager: ConversationManager
    @Query private var conversations: [Conversation]
    @State private var deleteConversation: Conversation?
    @State private var showAlert = false
    
    var body: some View {
        List {
            ForEach(conversations.sorted { $0.createdAt > $1.createdAt }, id: \.self) { conversation in
                Button(action: {
                    conversationManager.selectedConversation = conversation
                }) {
                    Text("\(conversation.messages.sorted { $0.timestamp > $1.timestamp }.first?.text ?? "(no text)")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .contentShape(Rectangle())
                }
                .background(conversationManager.selectedConversation == conversation ? Color.darkBlue : .clear)
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .contextMenu {
                    Button("Delete") {
                        deleteConversation = conversation
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("This is permanent."),
                        primaryButton: .destructive(Text("Delete"), action: {
                            modelContext.delete(deleteConversation!)
                        }),
                        secondaryButton: .default(Text("Cancel"))
                    )

                }
            }
        }
        .listStyle(SidebarListStyle())
        .onAppear(perform: {
            print(conversations)
        })
    }
}

#Preview {
    ChatView()
        .modelContainer(for: Message.self, inMemory: true)
}
