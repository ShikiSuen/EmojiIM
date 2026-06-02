import Combine
import Testing

@testable import LibEmojiIM

@Suite
struct AutomatonTests {
  let automaton: EmojiAutomaton
  let dictionary: EmojiDictionary

  init() {
    dictionary = EmojiDictionary()
    automaton = EmojiAutomaton(dictionary: dictionary)
  }

  /// Collects all values emitted by a publisher during a block.
  private func collect<P: Publisher>(
    from publisher: P,
    during block: () -> Void
  ) -> [P.Output] where P.Failure == Never {
    var values: [P.Output] = []
    let cancellable = publisher.sink { values.append($0) }
    defer { cancellable.cancel() }
    block()
    return values
  }

  private func last<P: Publisher>(
    from publisher: P,
    during block: () -> Void
  ) -> P.Output? where P.Failure == Never {
    collect(from: publisher, during: block).last
  }

  // MARK: - State Transitions

  @Test
  func initialStateIsNormal() {
    let state = last(from: automaton.state) { /* no-op */  }
    #expect(state == .normal)
  }

  @Test
  func enterDoesNothingInNormalState() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .enter, originalEvent: nil))
    }
    #expect(states.last == .normal)
  }

  @Test
  func randomInputDoesNothingInNormalState() {
    let handled = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
    #expect(!handled)
  }

  @Test
  func colonTransitionsToComposing() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
    }
    #expect(states.last == .composing)
  }

  @Test
  func inputKeepsComposingState() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "b"), originalEvent: nil))
    }
    #expect(states.last == .composing)
  }

  @Test
  func enterFromComposingReturnsToNormal() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .enter, originalEvent: nil))
    }
    #expect(states.last == .normal)
  }

  @Test
  func navigationTransitionsToSelection() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .navigation, originalEvent: nil))
    }
    #expect(states.last == .selection)
  }

  @Test
  func stayInSelectionOnNavigation() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .navigation, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .navigation, originalEvent: nil))
    }
    #expect(states.last == .selection)
  }

  @Test
  func enterDoesNotExitSelection() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .navigation, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .enter, originalEvent: nil))
    }
    #expect(states.last == .selection)
  }

  @Test
  func selectWhileSelectingReturnsToNormal() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .navigation, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .selected(emoji: "a"), originalEvent: nil))
    }
    #expect(states.last == .normal)
  }

  // MARK: - Handle Return Value

  @Test
  func handleReturnsFalseForUnhandledInput() {
    #expect(!automaton.handle(UserInput(eventType: .input(text: "x"), originalEvent: nil)))
    #expect(!automaton.handle(UserInput(eventType: .navigation, originalEvent: nil)))
    #expect(!automaton.handle(UserInput(eventType: .enter, originalEvent: nil)))
  }

  @Test
  func handleReturnsTrueForHandledInput() {
    #expect(automaton.handle(UserInput(eventType: .colon, originalEvent: nil)))
    #expect(automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil)))
    #expect(automaton.handle(UserInput(eventType: .navigation, originalEvent: nil)))
    #expect(automaton.handle(UserInput(eventType: .selected(emoji: "a"), originalEvent: nil)))
    #expect(!automaton.handle(UserInput(eventType: .enter, originalEvent: nil)))
  }

  // MARK: - Marked Text

  @Test
  func markedTextAccumulatesDuringComposing() {
    let values = collect(from: automaton.markedText) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
    }
    #expect(values.last == ":a")
  }

  @Test
  func backspaceRemovesLastMarkedCharacter() {
    let values = collect(from: automaton.markedText) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .backspace, originalEvent: nil))
    }
    #expect(values.last == ":")
  }

  @Test
  func backspaceAtColonReturnsToNormal() {
    let states = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "a"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .backspace, originalEvent: nil))
    }
    #expect(states.last == .composing)

    let states2 = collect(from: automaton.state) {
      _ = automaton.handle(UserInput(eventType: .backspace, originalEvent: nil))
    }
    #expect(states2.last == .normal)
  }

  @Test
  func enterCommitsMarkedText() {
    let values = collect(from: automaton.text) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .enter, originalEvent: nil))
    }
    #expect(values.last == ":")
  }

  // MARK: - Candidate Selection

  @Test
  func selectEmojiWhileComposingCommitsIt() {
    let values = collect(from: automaton.text) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "u"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .selected(emoji: "🍣"), originalEvent: nil))
    }
    #expect(values.last == "🍣")
  }

  @Test
  func candidatesAppearForMatchedPrefix() {
    let candidatesList = collect(from: automaton.candidates) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "u"), originalEvent: nil))
      _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
    }
    #expect((candidatesList.last ?? []).contains("🍣"))
  }

  @Test
  func candidatesUpdateAfterRefinement() {
    var list: [[String]] = []
    let c = automaton.candidates.sink { list.append($0) }
    defer { c.cancel() }

    _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .input(text: "u"), originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
    #expect(list.last?.contains("🍣") == true)

    _ = automaton.handle(UserInput(eventType: .input(text: "e"), originalEvent: nil))
    #expect(list.last?.contains("🍣") != true)
  }

  @Test
  func backspaceRestoresPreviousCandidates() {
    var list: [[String]] = []
    let c = automaton.candidates.sink { list.append($0) }
    defer { c.cancel() }

    _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .input(text: "u"), originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .input(text: "s"), originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .input(text: "e"), originalEvent: nil))
    _ = automaton.handle(UserInput(eventType: .backspace, originalEvent: nil))
    #expect(list.last?.contains("🍣") == true)
  }

  @Test
  func candidatesInitiallyEmpty() {
    let list = collect(from: automaton.candidates) {
      _ = automaton.handle(UserInput(eventType: .colon, originalEvent: nil))
    }
    #expect((list.last ?? []).isEmpty)
  }
}
