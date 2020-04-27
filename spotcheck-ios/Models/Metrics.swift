struct Metrics {
    var upvotes = 0
    var downvotes = 0
    var totalVotes: Int {
        get {
            return upvotes - downvotes
        }
    }
    var currentVoteDirection: VoteDirection = .neutral
}

enum VoteDirection: Int {
    case down = -1, neutral, up
    func get() -> Int {
        return self.rawValue
    }
}
