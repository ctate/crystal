import SwiftUI

struct ChatToolbarView: ToolbarContent {
    @EnvironmentObject var conversationManager: ConversationManager
    
    var sidebarAction: (() -> Void)? = {}
    var historyAction: (() -> Void)? = {}
    var settingsAction: (() -> Void)? = {}
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
        ToolbarItem(placement: .principal) {
            HStack {
                Image(findProviderByModelId(selectedModelId)?.image ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .forceDarkMode()
                Text(selectedModelId)
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(action: {
                showPopover = true
            }) {
                Image(systemName: showPopover ? "chevron.down" : "chevron.right")
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
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            
                            ForEach (provider.models) { model in
                                Button(action: {
                                    UserDefaults.standard.setValue(model.id, forKey: "defaultPromptModel")
                                    selectedModelId = model.id
                                    showPopover = false
                                }) {
                                    HStack {
                                        Text(model.name)
                                        Spacer()
                                        if selectedModelId == model.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                                .foregroundColor(.black)
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
                    settingsAction!()
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
