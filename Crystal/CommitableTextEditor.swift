import SwiftUI

#if os(macOS)
struct CommitableTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    var onCommit: (() -> Void)?
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.backgroundColor = .white
        textView.delegate = context.coordinator
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.isEditable = true
        textView.isRichText = false
        textView.textColor = .black
        textView.delegate = context.coordinator
        textView.textContainer?.containerSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.heightTracksTextView = false
        return textView
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != self.text {
            nsView.string = self.text
        }
        DispatchQueue.main.async {
            let calculatedHeight = nsView.layoutManager?.usedRect(for: nsView.textContainer!).height
            if calculatedHeight == nil {
                self.height = 0
            } else if calculatedHeight! > 100 {
                self.height = 100
            } else {
                self.height = calculatedHeight!
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CommitableTextEditor
        
        init(_ parent: CommitableTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            
            let calculatedHeight = textView.layoutManager?.usedRect(for: textView.textContainer!).height
            if calculatedHeight == nil {
                parent.height = 0
            } else if calculatedHeight! > 100 {
                parent.height = 100
            } else {
                parent.height = calculatedHeight!
            }
        }
        
//        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
//            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
//                let event = NSApp.currentEvent
//                if event?.modifierFlags.contains(.shift) == true {
//                    return true
//                }
//                parent.onCommit?()
//                return true
//            }
//            return true
//        }
    }
}

struct ExpandingTextField2: View {
    @State private var text: String = "Type something!"
    @State private var textHeight: CGFloat = 30
    
    var body: some View {
        ScrollView {
            CommitableTextEditor(text: $text, height: $textHeight)
                .frame(minHeight: textHeight, maxHeight: .infinity)
                .padding()
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    ExpandingTextField2()
}

#else
struct CommitableTextEditor: UIViewRepresentable {
    @Binding var text: String
    var onCommit: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = true
        textView.returnKeyType = .done
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CommitableTextEditor
        
        init(_ parent: CommitableTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                parent.onCommit?()
                return false
            }
            return true
        }
    }
}

#endif
