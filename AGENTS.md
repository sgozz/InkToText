# AGENTS.md — InkToText

iPadOS handwriting-recognition app (Apple Pencil). 100% Apple frameworks — no external dependencies.

---

## Project Overview

| | |
|---|---|
| **Language** | Swift 5.9+ |
| **UI** | SwiftUI (declarative) |
| **Target** | iPadOS 17.0+ |
| **Build** | Xcode 15+ |
| **Deps** | PencilKit · Vision · UIKit (all Apple) |
| **Architecture** | MVVM + actor-based services |

---

## Build & Run

This is an Xcode project — no `package.json`, no `npm`, no `Makefile`.

```bash
# Build from CLI (simulator)
xcodebuild -scheme InkToText \
           -destination 'platform=iOS Simulator,name=iPad Pro 12.9-inch' \
           build

# Run tests (once test targets exist)
xcodebuild -scheme InkToText \
           -destination 'platform=iOS Simulator,name=iPad Pro 12.9-inch' \
           test

# Run a single test class
xcodebuild -scheme InkToText \
           -destination 'platform=iOS Simulator,name=iPad Pro 12.9-inch' \
           -only-testing:InkToTextTests/CanvasViewModelTests \
           test

# Run a single test method
xcodebuild -scheme InkToText \
           -destination 'platform=iOS Simulator,name=iPad Pro 12.9-inch' \
           -only-testing:InkToTextTests/CanvasViewModelTests/testDebounce \
           test
```

> **Preferred**: Build & run via Xcode UI for device/simulator interaction.  
> No `swiftlint` or formatter configured — follow conventions below manually.

---

## Directory Structure

```
InkToText/
├── InkToTextApp.swift          # @main entry point
├── ContentView.swift            # Root view, NavigationStack, toolbar
├── ViewModels/
│   └── CanvasViewModel.swift    # @MainActor state + async logic
├── Views/
│   ├── CanvasView.swift         # UIViewRepresentable bridge to PKCanvasView
│   └── RecognizedTextView.swift # Presentational view (no business logic)
└── Services/
    └── HandwritingRecognizer.swift  # actor — Vision OCR
```

New files must follow this grouping: **Views/** for SwiftUI views, **ViewModels/** for ObservableObject classes, **Services/** for actors/pure logic.

---

## Architecture Rules

### MVVM — strict separation

- **Views** — SwiftUI `struct`s only. Zero business logic. Receive data via properties or closures.
- **ViewModels** — `class` + `ObservableObject` + `@MainActor`. Own `@Published` state. Call services. Handle debouncing.
- **Services** — `actor` (preferred) or free functions. No SwiftUI imports. No UI state.

### Concurrency

- `@MainActor` is **required** on every `ObservableObject` ViewModel.
- Use `async/await` — no callbacks/`DispatchQueue` except for legacy UIKit interop.
- Debounce with `Task.sleep` + `Task.isCancelled`, not `Timer`:

```swift
private var recognitionTask: Task<Void, Never>?

func onDrawingChanged() {
    recognitionTask?.cancel()
    recognitionTask = Task {
        try? await Task.sleep(nanoseconds: UInt64(0.8 * 1_000_000_000))
        guard !Task.isCancelled else { return }
        await performRecognition()
    }
}
```

- Bridge async to Vision/UIKit callbacks via `withCheckedThrowingContinuation`.
- Always check `Task.isCancelled` before writing `@Published` state after `await`.

### UIViewRepresentable

- Use a `Coordinator` (`NSObject`) subclass for delegate callbacks.
- Keep `updateUIView` minimal — prefer ViewModel-driven state.
- Store long-lived UIKit objects (e.g. `PKToolPicker`) in the Coordinator.

---

## Code Style

### Naming

- `camelCase` — variables, functions, properties
- `PascalCase` — types, structs, enums, protocols
- Descriptive names — `recognizedText`, `isRecognizing`, `onDrawingChanged()`
- Private helpers prefix with nothing (rely on `private` modifier)
- Boolean properties: `is`, `has`, `can` prefix (`isRecognizing`, `canUndo`)

### Imports

Always at file top, one per line, alphabetically within groups:

```swift
// Apple frameworks first
import PencilKit
import SwiftUI
import UIKit
import Vision
// Third-party (none currently)
```

No wildcard imports. Import only what the file needs.

### MARK sections

Group members with `// MARK: -` headers in this order:

```swift
// MARK: - Published State
// MARK: - Private
// MARK: - Init
// MARK: - <Feature Group>
// MARK: - Actions
```

Use `MARK` in every file with more than ~3 logical groups.

### Error Handling

Define errors as `enum` conforming to `LocalizedError` inside the responsible type:

```swift
enum RecognitionError: LocalizedError {
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Impossibile elaborare l'immagine dal canvas"
        }
    }
}
```

- Never swallow errors silently. At minimum, surface them in `@Published` state.
- User-facing error strings → Italian. Code/logs → English.

### Formatting

- 4-space indentation (Xcode default).
- Trailing comma on last enum case is fine.
- Opening brace on same line (`} else {`, `func foo() {`).
- Empty `updateUIView` body is acceptable: `func updateUIView(_ uiView: T, context: Context) {}`.

---

## Localization & Language

| Layer | Language |
|---|---|
| UI strings (labels, buttons, placeholders) | **Italian** |
| Error messages shown to user | **Italian** |
| Code, comments, MARK headers | **English** |

Example from `ContentView.swift`:
```swift
Label("Riconosci", systemImage: "text.viewfinder")   // ✅ Italian label
Label("Cancella", systemImage: "trash")               // ✅ Italian label
// Perform text recognition using Vision framework     // ✅ English comment
```

---

## SwiftUI Patterns

- Use `@StateObject` in the view that **owns** the ViewModel; `@ObservedObject` everywhere else.
- Prefer `Color(.secondarySystemBackground)` over hard-coded colors (dark mode support).
- Use `.animation(.easeInOut(duration: 0.2), value: someState)` for smooth transitions.
- Use `Label("Title", systemImage: "sf.symbol")` for icon+text buttons.
- Use `#Preview` macro (not `PreviewProvider`).

```swift
#Preview {
    ContentView()
}
```

---

## Testing

No tests exist yet. When adding them:

- Target name: `InkToTextTests` (XCTest framework)
- Mirror source structure: `InkToTextTests/ViewModels/CanvasViewModelTests.swift`
- Use `@MainActor` on test classes that test `@MainActor` ViewModels.
- Mock services by extracting protocols (e.g. `HandwritingRecognizerProtocol`).

---

## What NOT to Do

- **No third-party dependencies** — only Apple frameworks.
- **No `DispatchQueue.main.async`** for ViewModel updates — use `@MainActor`.
- **No business logic in Views** — move to ViewModel or Service.
- **No `UIScreen.main`** on iOS 16+ — use `GeometryReader` or `containerRelativeFrame`.
- **No forced unwraps** (`!`) except in `@IBOutlet` (none here) or provably-safe `guard`.
- **No hardcoded colors** — use semantic colors (`Color(.systemBackground)`, `.label`, `.separator`).
