import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

let bundleIdentifier = Bundle.main.bundleIdentifier ?? "unknown"

func copyTextToClipboard(text: String) {
    #if os(macOS)
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
    #elseif os(iOS)
    UIPasteboard.general.string = text
    #endif
}

func openLink(urlString: String) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
#if os(iOS)
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
#endif
    
#if os(macOS)
    NSWorkspace.shared.open(url)
#endif
}

func alertError(_ message: String) {
    NotificationCenter.default.post(
        name: .showGlobalAlert,
        object: nil,
        userInfo: ["title": "Error", "message": message]
    )
}
