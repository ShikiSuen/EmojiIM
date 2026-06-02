// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import Foundation

struct NormalMapping: MappingDefinition {
  func mappings(context: MappingContext) -> [Automaton<InputMethodState, UserInput>.Mapping] {
    [
      Automaton.Mapping(
        matchInput: { $0.eventType == .colon },
        matchState: { $0 == .normal },
        toState: .composing,
        action: { _, _, _ in
          Process.consoleLog("[EmojiIM] NormalMapping: colon → composing")
          context.markedText.send(":")
          context.candidates.send([])
        }
      )
    ]
  }
}
