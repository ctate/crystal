import SwiftUI
import SwiftData

struct ChatHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var conversationManager: ConversationManager
    @Query private var messages: [Message]
    
    var body: some View {
        if conversationManager.selectedConversation == nil || conversationManager.selectedConversation!.messages.isEmpty {
            Text("Nothing here yet")
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(conversationManager.selectedConversation!.messages.sorted { $0.timestamp < $1.timestamp }) { message in
                        HStack(alignment: .top) {
                            Image(message.role == "user" ? "UserIcon" : findProviderById(message.provider ?? "")?.image ?? "")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey(message.text))
                                    .textSelection(.enabled)
                                if message.provider != nil && message.model != nil {
                                    HStack {
                                        Button(action: {
                                            copyTextToClipboard(text: message.text)
                                        }) {
                                            Image(systemName: "doc.on.doc")
                                                .imageScale(.small)
                                                .foregroundColor(.white)
                                                .buttonStyle(PlainButtonStyle())
                                        }
                                        Button(action: {}) {
                                            Image(systemName: "arrow.clockwise")
                                                .imageScale(.small)
                                                .foregroundColor(.white)
                                                .buttonStyle(PlainButtonStyle())
                                        }
                                        Spacer()
                                        Text("\(message.tokensTotal!) tokens • \(message.model ?? "unknown")")
                                            .foregroundColor(.gray)
                                            .font(.footnote)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .onDelete(perform: deleteMessages)
                }
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
            }
        }
    }
    
    private func deleteMessages(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(messages[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Message.self, inMemory: true)
}
