// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import AppKit

final class EmojiDictionary: @unchecked Sendable {
  private struct Entry: Codable {
    let name: String
    let emoji: String
  }
  private let entries: [Entry]
  private let limit: Int

  init(limit: Int = 6) {
    self.limit = limit
    guard let url = Bundle.module.url(forResource: "EmojiDefinition", withExtension: "json") else {
      preconditionFailure("EmojiDefinition.json not found in bundle")
    }
    do {
      let data = try Data(contentsOf: url)
      entries = try JSONDecoder().decode([Entry].self, from: data)
    } catch {
      preconditionFailure("Failed to decode EmojiDefinition.json: \(error)")
    }
  }

  func find(prefix: String) -> [String] {
    entries.lazy.filter { $0.name.hasPrefix(prefix) }.prefix(limit).map(\.emoji)
  }
}
