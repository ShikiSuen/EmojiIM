// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import AppKit
import Combine

struct MappingContext {
  let candidates: CurrentValueSubject<[String], Never>
  let markedText: CurrentValueSubject<String, Never>
  let text: PassthroughSubject<String, Never>
  let candidateEvent: PassthroughSubject<NSEvent, Never>
  let dictionary: EmojiDictionary

  func clear() {
    markedText.send("")
    candidates.send([])
  }

  func forward(userInput: UserInput) {
    if let event = userInput.originalEvent {
      candidateEvent.send(event)
    }
  }
}
