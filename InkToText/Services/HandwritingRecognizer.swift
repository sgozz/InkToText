import Vision
import UIKit

actor HandwritingRecognizer {

    func recognize(image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw RecognitionError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                // Ordina le osservazioni dall'alto verso il basso (coordinate Vision sono invertite)
                let sorted = observations.sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }

                let text = sorted
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["it-IT", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    enum RecognitionError: LocalizedError {
        case invalidImage

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Impossibile elaborare l'immagine dal canvas"
            }
        }
    }
}
