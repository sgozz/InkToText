import SwiftUI
import PencilKit

@MainActor
class CanvasViewModel: ObservableObject {

    // MARK: - Published State

    @Published var recognizedText: String = ""
    @Published var isRecognizing: Bool = false
    @Published var canvasView = PKCanvasView()

    // MARK: - Private

    private let recognizer = HandwritingRecognizer()
    private var recognitionTask: Task<Void, Never>?

    private let debounceInterval: TimeInterval = 0.8

    // MARK: - Init

    init() {
        setupCanvas()
    }

    // MARK: - Canvas Setup

    private func setupCanvas() {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .label, width: 2)
        canvasView.backgroundColor = .secondarySystemBackground
        canvasView.isScrollEnabled = true
        canvasView.showsVerticalScrollIndicator = true
    }

    // MARK: - Drawing Changed

    func onDrawingChanged() {
        recognitionTask?.cancel()

        recognitionTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await performRecognition()
        }
    }

    // MARK: - Recognition

    func recognizeNow() async {
        recognitionTask?.cancel()
        await performRecognition()
    }

    private func performRecognition() async {
        let drawing = canvasView.drawing

        guard !drawing.strokes.isEmpty else {
            recognizedText = ""
            return
        }

        isRecognizing = true

        let image = drawing.image(
            from: drawing.bounds,
            scale: UIScreen.main.scale
        )

        do {
            let text = try await recognizer.recognize(image: image)
            if !Task.isCancelled {
                recognizedText = text
            }
        } catch {
            if !Task.isCancelled {
                recognizedText = "Errore nel riconoscimento: \(error.localizedDescription)"
            }
        }

        isRecognizing = false
    }

    // MARK: - Actions

    func clearCanvas() {
        recognitionTask?.cancel()
        canvasView.drawing = PKDrawing()
        recognizedText = ""
    }

    func undo() {
        canvasView.undoManager?.undo()
        onDrawingChanged()
    }

    func redo() {
        canvasView.undoManager?.redo()
        onDrawingChanged()
    }

    func copyText() {
        guard !recognizedText.isEmpty else { return }
        UIPasteboard.general.string = recognizedText
    }
}
