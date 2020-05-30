import Signals

struct StateManager {
    static var answerDeleted = Signal<Answer>()
    static var answerCreated = Signal<Answer>()
}
