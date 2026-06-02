// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import Combine

/// Generic state machine.  State and Input can be any type.
struct Automaton<State, Input> {

  /// A single transition rule.
  struct Mapping {
    let matchInput: (Input) -> Bool
    let matchState: (State) -> Bool
    let toState: State
    let action: (State, State, Input) -> Void
  }

  let state: CurrentValueSubject<State, Never>

  struct Reply {
    let fromState: State
    let toState: State?
    let input: Input
  }
  let reply: PassthroughSubject<Reply, Never>

  private let mappings: [Mapping]

  init(initialState: State, mappings: [Mapping]) {
    self.state = CurrentValueSubject(initialState)
    self.reply = PassthroughSubject()
    self.mappings = mappings
  }

  @discardableResult
  func handle(_ input: Input) -> Bool {
    let current = state.value
    for mapping in mappings {
      if mapping.matchInput(input), mapping.matchState(current) {
        state.send(mapping.toState)
        reply.send(Reply(fromState: current, toState: mapping.toState, input: input))
        mapping.action(current, mapping.toState, input)
        return true
      }
    }
    reply.send(Reply(fromState: current, toState: nil, input: input))
    return false
  }
}
