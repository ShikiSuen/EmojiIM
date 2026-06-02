import Testing

@testable import LibEmojiIM

@Suite
struct EmojiDictionaryTests {
  let dictionary = EmojiDictionary()

  @Test
  func findsSushi() {
    let sushi = dictionary.find(prefix: ":sus")
    #expect(sushi.contains("🍣"), "\(sushi) should contain 🍣")
  }

  @Test
  func findsBeer() {
    let beer = dictionary.find(prefix: ":beer")
    #expect(beer.contains("🍺"), "\(beer) should contain 🍺")
    #expect(beer.contains("🍻"), "\(beer) should contain 🍻")
  }

  @Test
  func returnsAtMostSixCandidates() {
    let all = dictionary.find(prefix: ":")
    #expect(all.count == 6)
  }

  @Test
  func emptyPrefixReturnsCandidates() {
    let result = dictionary.find(prefix: ":")
    #expect(!result.isEmpty)
  }

  @Test
  func unknownPrefixReturnsEmpty() {
    let result = dictionary.find(prefix: ":zzzzunknown")
    #expect(result.isEmpty)
  }
}
