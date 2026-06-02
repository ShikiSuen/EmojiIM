# AGENTS.md — EmojiIM

Guidance for AI agents (and humans) working on this codebase.

## Project Identity

EmojiIM is a macOS input method that converts GitHub-style emoji shorthand
(`:sushi:`) into emoji characters (🍣).  It is built on InputMethodKit and
distributed as a `.app` bundle registered with the system as an input source.

- **Language:** Swift 6.2 (strict concurrency, `swiftLanguageModes: [.v6]`)
- **Platform:** macOS 15+ (Sequoia)
- **Package manager:** Swift Package Manager (`Packages/LibEmojiIM/Package.swift`)
- **Xcode workspace:** `EmojiIM.xcworkspace` (thin wrapper around the SPM package)
- **Testing:** Swift Testing (`swift test` in `Packages/LibEmojiIM`)

## Repository Layout

```
EmojiIM/
├── Packages/LibEmojiIM/           # SPM package (all real code lives here)
│   ├── Package.swift              # swift-tools-version 6.2
│   ├── Sources/
│   │   ├── LibEmojiIM/            # Input method core
│   │   │   ├── Automaton/
│   │   │   │   ├── Dictionary/EmojiDictionary.swift
│   │   │   │   ├── InputMethodKit/EmojiIMSessionController.swift
│   │   │   │   ├── Mapping/       # ComposingMapping, NormalMapping, SelectionMapping
│   │   │   │   ├── EmojiAutomaton.swift
│   │   │   │   ├── InputMethodState.swift
│   │   │   │   ├── ReactiveAutomaton.swift
│   │   │   │   └── UserInput.swift
│   │   │   └── Resources/EmojiDefinition.json
│   │   ├── LibEmojiIMPreferences/ # PreferenceDelegate
│   │   └── LibEmojiIMSharedImpl/  # Building, SettingStore, TISInputSource, logging
│   └── Tests/LibEmojiIMTests/     # Swift Testing test suite (31 tests)
├── Sources/                       # AppDelegate (thin entry point)
├── Resources/                     # Info.plist, assets, entitlements
├── EmojiIM.xcodeproj/
└── EmojiIM.xcworkspace/
```

## Three Modules

| Module               | Responsibility                                    |
|----------------------|---------------------------------------------------|
| `LibEmojiIM`         | Automaton, mappings, dictionary, `EmojiIMSessionController`, `UserInput` |
| `LibEmojiIMPreferences` | Preferences pane delegate (thin)               |
| `LibEmojiIMSharedImpl`  | `BuildInfo`, `SettingStore`, `TISInputSource` extensions, `Process.consoleLog` |

`LibEmojiIM` depends on `LibEmojiIMSharedImpl` and `IMKSwift` (external).
`LibEmojiIMPreferences` depends on `LibEmojiIMSharedImpl`.

## How the Input Method Works

### Event Flow

```
User types key
  → NSEvent dispatched by InputMethodKit
    → EmojiIMSessionController.handle(_:client:)
      → convert(event:) maps keyCode → UserInput.EventType
        → Automaton<InputMethodState, UserInput>.handle(input)
          → iterates mappings, finds first match on state+input
            → mapping.action() fires Combine publishers
```

### States

```
normal ──colon──→ composing ──navigation──→ selection
  ↑                  ↑    │                      │
  │                  │    ├──enter──→ (commit)    │
  │                  │    └──backspace            │
  │                  │                           │
  └──selected(emoji)─┘───────────────────────────┘
```

### Mappings

- **NormalMapping** — `.colon` + `.normal` → `.composing`.  Sends `":"` as marked text.
- **ComposingMapping** — handles `.input`, `.backspace`, `.enter`, `.selected`, `.navigation` when composing.
- **SelectionMapping** — catch-all in `.selection` state.  Forwards original `NSEvent` to `IMKCandidates` via `interpretKeyEvents`.

### Candidate Window

```
ComposingMapping.action()
  → context.candidates.send(dictionary.find(prefix: markedText))
    → EmojiIMSessionController stores currentCandidates
      → candidates.setWindowLevel(…) + .update() + .show()
        → system calls candidates(_:) → returns currentCandidates
```

## Key Conventions

### Actor Isolation

All targets use `swiftSettings: [.defaultIsolation(MainActor.self)]`.  This means
every type, method, and property defaults to `@MainActor`.

The ObjC `init` path is nonisolated (called by IMK from non-MainActor context);
init-accessed properties use `nonisolated(unsafe)` to bridge this gap safely
(the runtime always calls init on the main thread).

### Logging

Use `Process.consoleLog("message")` — never `NSLog` or `print` directly.
On macOS 26+ this uses `OSLog` with `.public` privacy; on older systems it
falls back to `NSLog`.  Filter Console.app by `subsystem:EmojiIM`.

### Tests

All tests live in `Packages/LibEmojiIM/Tests/LibEmojiIMTests/` and use
Swift Testing (`@Suite`, `@Test`, `#expect`).  No XCTest imports.
Run with:

```sh
cd Packages/LibEmojiIM
swift test --disable-sandbox
```

### Resources

`EmojiDefinition.json` (~6K emoji entries) is declared as `.process("Resources")`
in the `LibEmojiIM` target.  SPM bundles it so `Bundle.module.url(forResource:)`
resolves at runtime.

## Do Not Do

- Do **not** add copyright headers to `Package.swift` — it breaks the manifest.
- Do **not** use `XCTest` / `XCTAssert` — the project uses Swift Testing only.
- Do **not** use `print()` or `NSLog()` directly — use `Process.consoleLog()`.
- Do **not** add CocoaPods, fastlane, or ReactiveSwift dependencies.
- Do **not** change `UserInput.EventType` cases without updating all three
  mapping files and the `convert(event:)` switch in `EmojiIMSessionController`.

## External Dependency

- [IMKSwift](https://github.com/vChewing/IMKSwift) — `@MainActor`-annotated InputMethodKit overlay.  Required by `LibEmojiIM` target, resolved via SPM.
