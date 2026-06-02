// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import AppKit

struct UserInput {
  enum EventType: Equatable {
    case backspace
    case colon
    case enter
    case input(text: String)
    case navigation
    case selected(emoji: String)
    var isInput: Bool {
      if case .input = self { return true }
      return false
    }
    var isSelected: Bool {
      if case .selected = self { return true }
      return false
    }
  }
  let eventType: EventType
  let originalEvent: NSEvent?
}
