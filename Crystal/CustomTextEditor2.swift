import SwiftUI

struct CustomTextEditor2: NSViewRepresentable {
    @Binding var text: String
    var onCmdEnter: () -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        textView.isEditable = true
        textView.delegate = context.coordinator
        textView.backgroundColor = .red
        textView.maxSize = CGSize(width: CGFloat.infinity, height: 100)  // Max height for text view content
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.containerSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let textView = nsView.documentView as? NSTextView {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onCmdEnter: onCmdEnter)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor2
        var onCmdEnter: () -> Void

        init(_ parent: CustomTextEditor2, onCmdEnter: @escaping () -> Void) {
            self.parent = parent
            self.onCmdEnter = onCmdEnter
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if NSEvent.modifierFlags.contains(.command) {
                    // Cmd+Enter was pressed
                    onCmdEnter()
                    return true
                }
            }
            return false
        }
    }
}

struct TestView: View {
    @State private var text: String = ""

    var body: some View {
        CustomTextEditor2(text: $text, onCmdEnter: handleCmdEnter)
            .frame(maxHeight: 100)  // Set the maximum height for the scroll view
            .border(Color.gray, width: 1)
    }

    func handleCmdEnter() {
        print("Cmd+Enter pressed!")
        // Perform actions when Cmd+Enter is pressed
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
