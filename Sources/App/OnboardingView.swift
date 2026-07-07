import SwiftUI

/// The container app exists mainly to register the Quick Look extension with
/// the system (macOS discovers app extensions inside launched apps) and to walk
/// a first-time user through enabling it. It intentionally does very little.
struct OnboardingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Markdown Previewer")
                        .font(.title).bold()
                    Text("Rich Quick Look previews for Markdown files")
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 14) {
                Step(number: 1, text: "Keep this app in your Applications folder so macOS keeps the extension registered.")
                Step(number: 2, text: "Enable the extension under System Settings → General → Login Items & Extensions → Quick Look.")
                Step(number: 3, text: "Select any .md file in Finder and press the Space bar.")
            }

            HStack {
                Button {
                    openExtensionSettings()
                } label: {
                    Label("Open Quick Look Settings", systemImage: "gearshape")
                }
                .controlSize(.large)

                Spacer()
            }

            Text("Tip: if a preview doesn't refresh, run `qlmanage -r` in Terminal to reset Quick Look's cache.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .frame(width: 460)
    }

    private func openExtensionSettings() {
        // Deep-links to the Extensions pane. Users pick "Quick Look" there.
        if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
            NSWorkspace.shared.open(url)
        }
    }
}

private struct Step: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.callout).bold().monospacedDigit()
                .frame(width: 24, height: 24)
                .background(Circle().fill(.tint.opacity(0.15)))
                .foregroundStyle(.tint)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
