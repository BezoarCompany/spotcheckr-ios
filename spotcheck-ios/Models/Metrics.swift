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
