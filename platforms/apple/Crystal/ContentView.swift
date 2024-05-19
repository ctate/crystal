import SwiftUI

struct ContentView: View {
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        Group {
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                WelcomeView()
            } else {
                ChatView()
            }
        }
        .onAppear(perform: setupNotificationObserver)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .showGlobalAlert, object: nil, queue: .main) { notification in
            if let userInfo = notification.userInfo, let title = userInfo["title"] as? String, let message = userInfo["message"] as? String {
                self.alertTitle = title
                self.alertMessage = message
                self.showAlert = true
            }
        }
    }
}
