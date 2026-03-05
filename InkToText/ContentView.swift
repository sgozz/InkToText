import SwiftUI
import PencilKit

struct ContentView: View {
    @StateObject private var viewModel = CanvasViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    CanvasView(viewModel: viewModel)
                        .frame(height: geometry.size.height * 0.6)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.separator, lineWidth: 1)
                        )
                        .padding(.horizontal)

                    Divider()
                        .padding(.vertical, 8)

                    ScrollView {
                        RecognizedTextView(
                            text: viewModel.recognizedText,
                            isRecognizing: viewModel.isRecognizing,
                            onCopy: { viewModel.copyText() }
                        )
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("InkToText")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        viewModel.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }

                    Button {
                        viewModel.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                    }

                    Button {
                        Task { await viewModel.recognizeNow() }
                    } label: {
                        Label("Riconosci", systemImage: "text.viewfinder")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        viewModel.clearCanvas()
                    } label: {
                        Label("Cancella", systemImage: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
