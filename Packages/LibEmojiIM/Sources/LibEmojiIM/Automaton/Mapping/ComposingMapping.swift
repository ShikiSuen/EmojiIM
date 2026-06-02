// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

struct ComposingMapping: MappingDefinition {
  func mappings(context: MappingContext) -> [Automaton<InputMethodState, UserInput>.Mapping] {
    [
      Automaton<InputMethodState, UserInput>.Mapping(
        matchInput: { $0.eventType.isInput },
        matchState: { $0 == .composing },
        toState: .composing,
        action: { _, _, input in
          if case .input(let text) = input.eventType {
            var current = context.markedText.value
            current.append(text)
            context.markedText.send(current)
            context.candidates.send(context.dictionary.find(prefix: current))
          }
        }
      ),
      Automaton.Mapping(
        matchInput: { $0.eventType == .backspace },
        matchState: { $0 == .composing && context.markedText.value.utf8.count <= 1 },
        toState: .normal,
        action: { _, _, _ in context.clear() }
      ),
      Automaton.Mapping(
        matchInput: { $0.eventType == .backspace },
        matchState: { $0 == .composing },
        toState: .composing,
        action: { _, _, _ in
          var current = context.markedText.value
          if !current.isEmpty { current.removeLast() }
          context.markedText.send(current)
          context.candidates.send(context.dictionary.find(prefix: current))
        }
      ),
      Automaton.Mapping(
        matchInput: { $0.eventType == .enter },
        matchState: { $0 == .composing },
        toState: .normal,
        action: { _, _, _ in
          context.text.send(context.markedText.value)
          context.clear()
        }
      ),
      Automaton.Mapping(
        matchInput: { $0.eventType.isSelected },
        matchState: { $0 == .composing },
        toState: .normal,
        action: { _, _, input in
          if case .selected(let emoji) = input.eventType { context.text.send(emoji) }
          context.clear()
        }
      ),
      Automaton.Mapping(
        matchInput: { $0.eventType == .navigation },
        matchState: { $0 == .composing },
        toState: .selection,
        action: { _, _, input in context.forward(userInput: input) }
      ),
    ]
  }
}
