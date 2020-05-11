import IGListKit

extension Answer: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.id!.value as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let answer = (object as? Answer) else {
            return false
        }

        if self.dateModified != answer.dateModified
            || self.text != answer.text
            || self.metrics?.currentVoteDirection != answer.metrics?.currentVoteDirection {
            return false
        }

        return true
    }
}
