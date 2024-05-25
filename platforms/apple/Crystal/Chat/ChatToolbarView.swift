import SwiftUI

struct ChatToolbarView: ToolbarContent {
    @EnvironmentObject var conversationManager: ConversationManager
    
    var sidebarAction: (() -> Void)? = {}
    var historyAction: (() -> Void)? = {}
    var settingsAction: ((_ name: String) -> Void)? = { _ in }
    var newAction: (() -> Void)? = {}
    
    @State private var functionsDisabled = UserDefaults.standard.bool(forKey: "functionsDisabled")
    @State private var selectedModelId: String = UserDefaults.standard.string(forKey: "defaultPromptModel") ?? "Choose Model"
    
    @State private var showHistorySheet = false
    @State private var showPopover = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button(action: {
                if sidebarAction != nil {
                    sidebarAction!()
                }
            }) {
                Image(systemName: "sidebar.left")
                    .foregroundColor(.white)
            }
            .keyboardShortcut("/", modifiers: .command)
        }
        ToolbarItem(placement: .navigation) {
            Button(action: {
                showPopover = true
            }) {
                HStack(alignment: .center) {
                    Image(findProviderByModelId(selectedModelId)?.image ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    
                    Text(selectedModelId)
                        .foregroundColor(.white)
                    
                    Image(systemName: showPopover ? "chevron.down" : "chevron.right")
                }
            }
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                ScrollView {
                    ForEach(Array(providers.enumerated()), id: \.element) { index, provider in
                        VStack(alignment: .leading) {
                            if index != 0 {
                                Divider()
                            }

                            HStack {
                                Image(provider.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                
                                Text(provider.name)
                                    .bold()
                                
                                if !UserDefaults.standard.bool(forKey: "\(provider.id):isEnabled") {
                                    Text("(Disabled)")
                                        .bold()
                                    Spacer()
                                    Button(action: {
                                        if settingsAction != nil {
                                            settingsAction!("models")
                                        }
                                    }) {
                                        Text("Settings")
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            
                            ForEach (provider.models) { model in
                                Button(action: {
                                    UserDefaults.standard.setValue(model.id, forKey: "defaultPromptModel")
                                    UserDefaults.standard.setValue(provider.id, forKey: "defaultPromptProvider")
                                    selectedModelId = model.id
                                    showPopover = false
                                }) {
                                    HStack {
                                        Text(model.name)
                                            .foregroundColor(!UserDefaults.standard.bool(forKey: "\(provider.id):isEnabled") ? .gray : .primary)
                                        Spacer()
                                        if selectedModelId == model.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                .disabled(!UserDefaults.standard.bool(forKey: "\(provider.id):isEnabled"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
        ToolbarItemGroup(placement: .automatic) {
            Spacer()
            
            if conversationManager.selectedConversation != nil {
                Button(action: {
                    if historyAction != nil {
                        historyAction!()
                    }
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.white)
                }
            }
            
#if os(iOS)
            Button(action: {
                if settingsAction != nil {
                    settingsAction!("general")
                }
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.white)
            }
#endif

            Button(action: {
                functionsDisabled = !functionsDisabled
                UserDefaults.standard.setValue(functionsDisabled, forKey: "functionsDisabled")
            }) {
                Image(systemName: "function")
                    .foregroundColor(functionsDisabled ? .white : .green)
            }
            
            Button(action: {
                if newAction != nil {
                    newAction!()
                }
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
}
