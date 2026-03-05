import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @ObservedObject var viewModel: CanvasViewModel

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = viewModel.canvasView
        canvas.delegate = context.coordinator
        canvas.isOpaque = false

        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        context.coordinator.toolPicker = toolPicker

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let viewModel: CanvasViewModel
        var toolPicker: PKToolPicker?

        init(viewModel: CanvasViewModel) {
            self.viewModel = viewModel
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            viewModel.onDrawingChanged()
        }
    }
}
