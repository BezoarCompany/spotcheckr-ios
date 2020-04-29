extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func stringAt(_ index: Int) -> String {
        return String(Array(self)[index])
    }

    func charAt(_ index: Int) -> Character {
        return Array(self)[index]
    }
}
