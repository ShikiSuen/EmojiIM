# EmojiIM: Emoji Input Method for macOS

[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![macOS 15+](https://img.shields.io/badge/macOS-15%2B-blue)](https://developer.apple.com/macos/)
[![License MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

EmojiIM converts GitHub-style emoji codes (`:sushi:`) into emoji characters (🍣)
as you type.  It is a macOS input method built on InputMethodKit.

![sushi](docs/sushi.gif)

## Project Goals

- Provide a fast, lightweight emoji input method for macOS.
- Serve as a playground for investigating InputMethodKit internals.
- Maintain a clean, modern Swift 6 codebase with zero legacy dependencies.

## Architecture

```
NSEvent  →  EmojiIMSessionController.handle()
            →  Automaton (state machine)
              →  Mapping (transition rules)
                →  EmojiDictionary (JSON lookup)
                  →  Combine publishers
                    →  IMKCandidates
```

| Module               | Role                                        |
|----------------------|---------------------------------------------|
| `LibEmojiIM`         | Input method core: automaton, dictionary, IMK controller |
| `LibEmojiIMPreferences` | Preferences pane delegate                |
| `LibEmojiIMSharedImpl`  | Shared utilities: BuildInfo, SettingStore, TISInputSource, logging |

### Key Design Decisions

- **Combine-based automaton** instead of ReactiveSwift.
- **`@MainActor` isolation** on all UI-facing code via SPM `defaultIsolation(MainActor.self)`.
- **Swift Testing** for all unit tests (no XCTest).
- **Swift 6 strict concurrency** with `swiftLanguageModes: [.v6]`.
- **IMKSwift** for modernized InputMethodKit bridging with `@MainActor` annotations.

## Build

```sh
cd Packages/LibEmojiIM
swift build
```

### Run Tests

```sh
cd Packages/LibEmojiIM
swift test
```

### Build & Install the App

Open `EmojiIM.xcworkspace` in Xcode, select the **EmojiIM** scheme, and build.
After a logout/login cycle, EmojiIM appears in System Settings → Keyboard → Input Sources.

## Requirements

- macOS 15 (Sequoia) or later
- Xcode 26 or later (Swift 6.2)
- [IMKSwift](https://github.com/vChewing/IMKSwift) (resolved automatically via SPM)

## License

MIT — see [LICENSE](LICENSE).

---

## :smile: Commit symbol

#### What's mean of this task
|emoji              |mean                                    |
|-------------------|----------------------------------------|
|:rotating_light:   |add/improve test                        |
|:sparkles:         |add new feature                         |
|:lipstick:         |improve the format/structure of the code|
|:bug:              |fix bug                                 |
|:wrench:           |improve development environment         |
|:memo:             |improve document                        |

#### What's do for this task
|emoji              |mean                                    |
|-------------------|----------------------------------------|
|:hocho:            |split code                              |
|:truck:            |move files                              |
|:fire:             |remove code/files/...                   |
|:chocolate_bar:    |install/remove new cocoapods            |
|:see_no_evil:      |ignore something                        |

### Where's updated for this task
|emoji              |mean                                    |
|-------------------|----------------------------------------|
|:fountain_pen:     |update something around InputMethodKit  |
|:twisted_rightwards_arrows: |update state machine definition|
|:books:            |update something around dictionary      |

### Other
|emoji              |mean                                    |
|-------------------|----------------------------------------|
|:police_car:|improve code format drived by lint police|
|:lock:      |improve something related with signing   |

$ EOF.
