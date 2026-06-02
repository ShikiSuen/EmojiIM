import Carbon.HIToolbox
import Testing

@testable import LibEmojiIMSharedImpl

@Suite
struct TISInputSourceTests {

  @Test
  func keyboardLayoutsReturnsNonEmptyList() {
    let layouts = TISInputSource.keyboardLayouts()
    #expect(layouts != nil)
    #expect(!(layouts?.isEmpty ?? true))
  }

  @Test
  func englishLayoutsHaveScriptCodeZero() {
    let englishLayouts = TISInputSource.keyboardLayouts()?
      .filter { $0.scriptCode == 0 }
    #expect(englishLayouts != nil)
    #expect(!(englishLayouts?.isEmpty ?? true))
  }

  @Test
  func localizedNameContainsABC() {
    let names = TISInputSource.keyboardLayouts()?
      .filter { $0.scriptCode == 0 }
      .map(\.localizedName)
    #expect(names?.contains("ABC") == true)
  }

  @Test
  func scriptCodeZeroFiltersCorrectly() {
    // All layouts returned by the scriptCode==0 filter should indeed have scriptCode == 0
    let filtered = TISInputSource.keyboardLayouts()?
      .filter { $0.scriptCode == 0 }
    #expect(filtered != nil)
    #expect(filtered?.allSatisfy { $0.scriptCode == 0 } == true)
  }

  @Test
  func inputSourceIDIsNotEmpty() {
    guard let layouts = TISInputSource.keyboardLayouts(), let first = layouts.first else {
      #expect(Bool(false), "No keyboard layouts found")
      return
    }
    #expect(!first.inputSourceID.isEmpty)
  }
}
