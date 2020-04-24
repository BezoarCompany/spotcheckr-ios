extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func stringAt(_ i: Int) -> String {
        return String(Array(self)[i])
    }
    
    func charAt(_ i: Int) -> Character {
        return Array(self)[i]
    }
}
