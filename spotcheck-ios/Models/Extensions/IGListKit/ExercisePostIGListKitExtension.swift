import IGListKit

extension ExercisePost: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.id!.value as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let post = (object as? ExercisePost) else {
            return false
        }

        if self.dateModified != post.dateModified
            || self.title != post.title
            || self.description != post.description
            || self.imagePath != post.imagePath
            || self.videoPath != post.videoPath {
            return false
        }

        return true
    }
}
