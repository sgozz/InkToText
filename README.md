# InkToText

App iPadOS per riconoscimento scrittura a mano con Apple Pencil.
Scrivi sul canvas e il testo viene convertito in tempo reale.

## Setup in Xcode

1. Apri Xcode → **File → New → Project**
2. Scegli **iOS → App**
3. Configura:
   - Product Name: `InkToText`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Deployment Target: **iOS 17.0**
4. Cancella il `ContentView.swift` generato automaticamente
5. Trascina tutti i file `.swift` dalla cartella `InkToText/` nel progetto Xcode:
   - `InkToTextApp.swift`
   - `ContentView.swift`
   - `Views/CanvasView.swift`
   - `Views/RecognizedTextView.swift`
   - `Services/HandwritingRecognizer.swift`
   - `ViewModels/CanvasViewModel.swift`
6. Build & Run su iPad (simulatore o device fisico)

## Requisiti

- Xcode 15+
- iOS/iPadOS 17.0+
- Nessuna dipendenza esterna (100% Apple frameworks)

## Frameworks Utilizzati

- **PencilKit** — Canvas per scrittura con Apple Pencil
- **Vision** — OCR/riconoscimento testo (VNRecognizeTextRequest)
- **SwiftUI** — UI dichiarativa

## Funzionalita

- Scrittura con Apple Pencil o dito
- Riconoscimento automatico con debounce (0.8s dopo ultimo tratto)
- Riconoscimento manuale con bottone
- Supporto italiano + inglese con correzione linguistica
- Undo/Redo tratti
- Copia testo negli appunti
- Tool picker PencilKit nativo (penna, matita, evidenziatore, gomma)
- Dark mode supportato
