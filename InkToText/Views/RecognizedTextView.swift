import SwiftUI

struct RecognizedTextView: View {
    let text: String
    let isRecognizing: Bool
    let onCopy: () -> Void

    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Testo Riconosciuto", systemImage: "text.viewfinder")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                if isRecognizing {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Riconoscimento...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !text.isEmpty {
                    Button {
                        onCopy()
                        showCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showCopied = false
                        }
                    } label: {
                        Label(
                            showCopied ? "Copiato!" : "Copia",
                            systemImage: showCopied ? "checkmark" : "doc.on.doc"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(showCopied ? .green : .accentColor)
                }
            }

            if text.isEmpty && !isRecognizing {
                Text("Scrivi qualcosa sul canvas...")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .italic()
            } else {
                Text(text)
                    .font(.title3)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: text)
        .animation(.easeInOut(duration: 0.2), value: isRecognizing)
    }
}
