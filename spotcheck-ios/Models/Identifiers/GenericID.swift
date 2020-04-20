class GenericID: Hashable {
    var value: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
    var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
    static func == (lhs: GenericID, rhs: GenericID) -> Bool {
        return lhs.value == rhs.value
    }
    
    var description: String {
        return value
    }
    
    init(_ id: String) {
        self.value = id
    }
}
