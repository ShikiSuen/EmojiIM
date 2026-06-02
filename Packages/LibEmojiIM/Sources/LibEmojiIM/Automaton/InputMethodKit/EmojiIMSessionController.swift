// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import Combine
import CoreGraphics
import Foundation
import IMKSwift
import LibEmojiIMSharedImpl

// MARK: - EmojiIMSessionController

@objc(EmojiIMSessionController)
final class EmojiIMSessionController: IMKInputSessionController {
  private let automaton: EmojiAutomaton
  private let candidates: IMKCandidates
  private var cancellables = Set<AnyCancellable>()
  private var currentCandidates: [String] = []
  private var directMode: Bool = false
  private let printable: CharacterSet = CharacterSet.alphanumerics
    .union(.symbols)
    .union(.punctuationCharacters)

  override init(server: IMKServer, delegate: Any?, client inputClient: any IMKTextInput) {
    automaton = EmojiAutomaton(dictionary: EmojiDictionary())
    candidates = IMKCandidates(server: server, panelType: kIMKSingleColumnScrollingCandidatePanel)
    super.init(server: server, delegate: delegate, client: inputClient)

    let notFound = NSRange(location: NSNotFound, length: NSNotFound)

    automaton.markedText
      .sink { inputClient.setMarkedText($0, selectionRange: notFound, replacementRange: notFound) }
      .store(in: &cancellables)
    automaton.text
      .sink { inputClient.insertText($0, replacementRange: notFound) }
      .store(in: &cancellables)
    automaton.candidates
      .sink { [weak self] list in
        guard let self else { return }
        self.currentCandidates = list
        if list.isEmpty {
          self.candidates.hide()
        } else {
          self.setCandidatesWindowLevel()
          self.candidates.update()
          self.candidates.show()
        }
      }
      .store(in: &cancellables)
    automaton.candidateEvent
      .sink { [weak self] in self?.candidates.interpretKeyEvents([$0]) }
      .store(in: &cancellables)
  }

  override func handle(_ event: NSEvent?, client sender: any IMKTextInput) -> Bool {
    guard !directMode else { return false }
    guard let event else {
      Process.consoleLog("[EmojiIM] handle called with nil event")
      return false
    }
    let eventType = convert(event: event)
    let input = UserInput(eventType: eventType, originalEvent: event)
    let handled = automaton.handle(input)
    Process.consoleLog("[EmojiIM] handle key=\(event.keyCode) chars=\(event.characters ?? "nil") type=\(eventType) handled=\(handled)")
    return handled
  }

  override func menu() -> NSMenu? {
    let menu = NSMenu(title: "EmojiIM")
    menu.addItem(NSMenuItem(title: Bundle.kBuiltDate, action: nil, keyEquivalent: ""))
    menu.addItem(NSMenuItem(title: Bundle.kRevision, action: nil, keyEquivalent: ""))
    return menu
  }

  private func setCandidatesWindowLevel() {
    let level = Int(max(CGShieldingWindowLevel(), kCGPopUpMenuWindowLevel)) + 2
    candidates.setWindowLevel(UInt64(level))
  }

  private func convert(event: NSEvent) -> UserInput.EventType {
    if event.keyCode == UInt16(kVK_Return) { return .enter }
    if event.keyCode == UInt16(kVK_Delete) { return .backspace }
    if let text = event.characters {
      if text == ":" { return .colon }
      if text.unicodeScalars.allSatisfy(printable.contains) { return .input(text: text) }
      return .navigation
    }
    return .navigation
  }
}

extension EmojiIMSessionController {
  override func activateServer(_ client: any IMKTextInput) {
    client.overrideKeyboard(withKeyboardNamed: "com.apple.keylayout.US")
  }
  override func deactivateServer(_ sender: any IMKTextInput) { candidates.hide() }
  override func setValue(_ value: Any?, forTag tag: Int, client sender: any IMKTextInput) {
    guard let value = value as? NSString else { return }
    directMode = value == "com.apple.inputmethod.Roman"
    sender.overrideKeyboard(withKeyboardNamed: "com.apple.keylayout.US")
  }
  override func candidates(_ sender: any IMKTextInput) -> [Any]? { currentCandidates }
  override func candidateSelected(_ candidateString: NSAttributedString?) {
    guard let candidateString else { return }
    _ = automaton.handle(UserInput(eventType: .selected(emoji: candidateString.string), originalEvent: nil))
  }
  override func candidateSelectionChanged(_ candidateString: NSAttributedString?) {}
}
