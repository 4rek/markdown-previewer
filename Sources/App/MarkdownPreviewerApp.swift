import SwiftUI

@main
struct MarkdownPreviewerApp: App {
    var body: some Scene {
        Window("Markdown Previewer", id: "main") {
            OnboardingView()
        }
        .windowResizability(.contentSize)
    }
}
