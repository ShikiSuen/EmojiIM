import Combine

/// 泛型狀態機。State 和 Input 可以是任意型別。
struct Automaton<State, Input> {

    /// 一條轉換規則
    struct Mapping {
        /// 這個規則是否適用於此輸入？
        let matchInput: (Input) -> Bool
        /// 這個規則是否適用於當前狀態？
        let matchState: (State) -> Bool
        /// 目標狀態
        let toState: State
        /// 轉換時執行的副作用
        let action: (State, State, Input) -> Void
    }

    /// 當前狀態
    let state: CurrentValueSubject<State, Never>

    /// 轉換結果。成功時 toState 為目標狀態，無匹配規則時為 nil
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

    /// 處理一個輸入。回傳 true 表示有匹配的規則。
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
