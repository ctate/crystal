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
    @State private var keyboardHeight: CGFloat = 0
    @State var presentSheet = ""
    @State private var defaultSettingsTab = "general"
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
#if os(iOS)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
#endif
            }
            
            HStack(alignment: .bottom) {
                Button(action: {
                    presentSheet = "camera"
                }) {
                    Image(systemName: "camera")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 20)
                
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
#if os(iOS)
                        TextField("Say something...", text: $userInput, axis: .vertical)
                            .onSubmit {
                                viewModel.sendMessage(
                                    userInput,
                                    conversationManager: conversationManager,
                                    modelContext: modelContext
                                )
                                userInput = ""
                            }
                            .textFieldStyle(.roundedBorder)
                            .padding()
#else
                        CustomTextEditor(text: $userInput)
#endif
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if userInput.isEmpty {
                        showRecorder.toggle()
                    } else {
                        viewModel.sendMessage(
                            userInput,
                            conversationManager: conversationManager,
                            modelContext: modelContext
                        )
                        userInput = ""
                    }
                }) {
                    Image(systemName: userInput.isEmpty ? "mic" : "arrow.up")
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
                .padding(.bottom, 20)
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
                NavigationView {
                    SettingsView(selectedTab: defaultSettingsTab)
                }
            default:
                Text("No sheet")
            }
        })
        .onChange(of: conversationManager.selectedConversation, {
            if conversationManager.selectedConversation != nil {
                let messages = conversationManager.selectedConversation!.messages.sorted { $0.timestamp < $1.timestamp }
                
                guard let lastMessage = messages.last, lastMessage.role == "assistant" else {
                    return
                }
                
                viewModel.updateViewBasedOnLastMessage(
                    lastMessage: lastMessage
                )
            }
        })
        .toolbar {
            ChatToolbarView(sidebarAction: {
                if sidebarAction != nil {
                    sidebarAction!()
                }
            }, historyAction: {
                presentSheet = "history"
            }, settingsAction: { tab in
                defaultSettingsTab = tab
                presentSheet = "settings"
            }, newAction: {
                viewModel.currentView = AnyView(TextCard(text: "How can I help?"))
                conversationManager.selectedConversation = nil
            })
        }
#if os(iOS)
        .padding(.bottom, keyboardHeight)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                let height = value.height
                keyboardHeight = 1
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
#endif
    }
}

struct ChatView: View {
    @State private var isSidebarVisible: Bool = false
    @State private var dragOffset: CGFloat = 0
    private var sidebarWidth: CGFloat {
#if os(macOS)
        return 300
#else
        return UIScreen.main.bounds.width * 0.75
#endif
    }
    
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
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                SidebarView(sidebarAction: {
                    withAnimation {
                        isSidebarVisible = false
                        dragOffset = 0
                    }
                })
                    .frame(width: sidebarWidth)
                
                NavigationView {
                    ChatContentView(sidebarAction: {
                        withAnimation {
                            isSidebarVisible.toggle()
                            if isSidebarVisible {
                                dragOffset = sidebarWidth
                            } else {
                                dragOffset = 0
                            }
                        }
                    })
                }
                .frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width + sidebarWidth)
            .offset(x: -sidebarWidth + dragOffset)
            .animation(.interactiveSpring(), value: dragOffset)
            .gesture(
                DragGesture().onChanged { gesture in
                    let newOffset = gesture.translation.width + (isSidebarVisible ? sidebarWidth : 0)
                    if newOffset > 0 {
                        dragOffset = min(newOffset, sidebarWidth)
                    }
                }
                .onEnded { gesture in
                    let threshold = sidebarWidth / 2
                    if dragOffset > threshold {
                        isSidebarVisible = true
                    } else {
                        isSidebarVisible = false
                    }
                    dragOffset = isSidebarVisible ? sidebarWidth : 0
                }
            )
            .onChange(of: isSidebarVisible) {
                if isSidebarVisible {
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    generator.notificationOccurred(.success)
                }
            }
        }
#endif
    }
}

struct SidebarView: View {
    var sidebarAction: (() -> Void)? = {}
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var conversationManager: ConversationManager
    @Query private var conversations: [Conversation]
    @State private var deleteConversation: Conversation?
    @State private var showAlert = false
    
    var body: some View {
        ScrollView {
            ForEach(conversations.sorted { $0.createdAt > $1.createdAt }, id: \.self) { conversation in
                Button(action: {
                    conversationManager.selectedConversation = conversation
                    if sidebarAction != nil {
                        sidebarAction!()
                    }
                }) {
                    Text("\(conversation.messages.sorted { $0.timestamp > $1.timestamp }.first?.text ?? "(no text)")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(conversationManager.selectedConversation == conversation ? .white : .primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
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
    }
}

#Preview {
    ChatView()
        .modelContainer(for: Message.self, inMemory: true)
}
