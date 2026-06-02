import Combine

struct MappingContext {
    let candidates: CurrentValueSubject<[String], Never>
    let markedText: CurrentValueSubject<String, Never>
    let text: PassthroughSubject<String, Never>
    let candidateEvent: PassthroughSubject<NSEvent, Never>
    let dictionary: EmojiDictionary

    func clear() {
        markedText.send("")
        candidates.send([])
    }

    func forward(userInput: UserInput) {
        if let event = userInput.originalEvent {
            candidateEvent.send(event)
        }
    }
}
