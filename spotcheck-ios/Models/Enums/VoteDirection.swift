enum VoteDirection: Int {
    case down = -1, neutral, up
    func get() -> Int {
        return self.rawValue
    }
}
