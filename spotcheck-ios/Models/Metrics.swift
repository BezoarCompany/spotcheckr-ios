struct Metrics {
    var views = 0
    var likes = 0
    var upvotes = 0
    var downvotes = 0
    var totalVotes: Int {
        get {
            return upvotes - downvotes
        }
    }
}
