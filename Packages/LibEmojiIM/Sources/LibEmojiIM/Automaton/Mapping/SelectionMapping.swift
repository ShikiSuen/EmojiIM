// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

struct SelectionMapping: MappingDefinition {
  func mappings(context: MappingContext) -> [Automaton<InputMethodState, UserInput>.Mapping] {
    [
      Automaton.Mapping(
        matchInput: { $0.eventType.isSelected },
        matchState: { $0 == .selection },
        toState: .normal,
        action: { _, _, input in
          if case .selected(let emoji) = input.eventType { context.text.send(emoji) }
          context.clear()
        }
      ),
      Automaton.Mapping(
        matchInput: { _ in true },
        matchState: { $0 == .selection },
        toState: .selection,
        action: { _, _, input in context.forward(userInput: input) }
      ),
    ]
  }
}
