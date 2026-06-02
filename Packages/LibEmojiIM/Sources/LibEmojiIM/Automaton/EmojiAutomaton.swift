// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import AppKit
import Combine

final class EmojiAutomaton {
  let state: AnyPublisher<InputMethodState, Never>
  let markedText: AnyPublisher<String, Never>
  let candidates: AnyPublisher<[String], Never>
  let text: AnyPublisher<String, Never>
  let candidateEvent: AnyPublisher<NSEvent, Never>

  private let automaton: Automaton<InputMethodState, UserInput>

  init(dictionary: EmojiDictionary) {
    let markedTextSubject = CurrentValueSubject<String, Never>("")
    let candidatesSubject = CurrentValueSubject<[String], Never>([])
    let textSubject = PassthroughSubject<String, Never>()
    let candidateEventSubject = PassthroughSubject<NSEvent, Never>()

    let context = MappingContext(
      candidates: candidatesSubject,
      markedText: markedTextSubject,
      text: textSubject,
      candidateEvent: candidateEventSubject,
      dictionary: dictionary
    )

    let definitions: [MappingDefinition] = [
      ComposingMapping(),
      NormalMapping(),
      SelectionMapping(),
    ]
    let allMappings = definitions.flatMap { $0.mappings(context: context) }

    automaton = Automaton(initialState: .normal, mappings: allMappings)

    self.state = automaton.state.eraseToAnyPublisher()
    self.markedText = markedTextSubject.eraseToAnyPublisher()
    self.candidates = candidatesSubject.eraseToAnyPublisher()
    self.text = textSubject.eraseToAnyPublisher()
    self.candidateEvent = candidateEventSubject.eraseToAnyPublisher()
  }

  @discardableResult
  func handle(_ input: UserInput) -> Bool {
    automaton.handle(input)
  }
}
