struct Metrics {
    var upvotes = 0
    var downvotes = 0
    var totalVotes: Int {
        get {
            return upvotes - downvotes
        }
    }
    var currentVoteDirection: VoteDirection = .Neutral
}

enum VoteDirection: Int {
    case Down = -1, Neutral, Up
    func get() -> Int {
        return self.rawValue
    }
}
