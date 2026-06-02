// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import Carbon.HIToolbox

// kTISPropertyScriptCode is deprecated and not available in newer SDKs
private var kTISPropertyScriptCode: CFString { "TISPropertyScriptCode" as CFString }

extension TISInputSource {
  public var localizedName: String {
    unsafeBitCast(TISGetInputSourceProperty(self, kTISPropertyLocalizedName), to: NSString.self) as String
  }
  public var inputSourceID: String {
    unsafeBitCast(TISGetInputSourceProperty(self, kTISPropertyInputSourceID), to: NSString.self) as String
  }
  public var scriptCode: Int? {
    let r = TISGetInputSourceProperty(self, kTISPropertyScriptCode)
    return unsafeBitCast(r, to: NSString.self).integerValue
  }
  public class func keyboardLayouts() -> [TISInputSource]? {
    let conditions = CFDictionaryCreateMutable(nil, 2, nil, nil)
    CFDictionaryAddValue(
      conditions,
      unsafeBitCast(kTISPropertyInputSourceType, to: UnsafeRawPointer.self),
      unsafeBitCast(kTISTypeKeyboardLayout, to: UnsafeRawPointer.self)
    )
    CFDictionaryAddValue(
      conditions,
      unsafeBitCast(kTISPropertyInputSourceIsASCIICapable, to: UnsafeRawPointer.self),
      unsafeBitCast(kCFBooleanTrue, to: UnsafeRawPointer.self)
    )
    guard let array = TISCreateInputSourceList(conditions, true) else { return nil }
    guard let keyboards = array.takeRetainedValue() as? [TISInputSource] else { return nil }
    return keyboards.sorted { $0.localizedName < $1.localizedName }
  }
}
