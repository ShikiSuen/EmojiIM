// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import Foundation

@MainActor
public final class SettingStore: ObservableObject {
  private static let suiteName = "jp.mzp.inputmethod.EmojiIM"

  @Published public var keyboardLayoutID: String

  private var defaults: UserDefaults? {
    Bundle.main.bundleIdentifier == Self.suiteName ? .standard : UserDefaults(suiteName: Self.suiteName)
  }

  public init() {
    let ud =
      Bundle.main.bundleIdentifier == Self.suiteName
      ? UserDefaults.standard
      : UserDefaults(suiteName: Self.suiteName)
    keyboardLayoutID = ud?.string(forKey: "keyboardLayout") ?? "com.apple.keylayout.US"
  }

  public func save() {
    defaults?.set(keyboardLayoutID, forKey: "keyboardLayout")
  }
}
