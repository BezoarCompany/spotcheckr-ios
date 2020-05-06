import IGListKit

class ExercisePostDetailSectionModel: ListDiffable {
    var screen: PostDetailViewModel?

    //To define the unique identifying attribute of a post
    func diffIdentifier() -> NSObjectProtocol {
        return (self.screen?.post?.id!.value)! as NSObjectProtocol
    }

    //equality operator
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let post = (object as? ExercisePost) else {
            return false
        }

        if self.screen?.post?.dateModified != post.dateModified
            || self.screen?.post?.title != post.title
            || self.screen?.post?.description != post.description
            || self.screen?.post?.imagePath != post.imagePath
            || self.screen?.post?.videoPath != post.videoPath {
            return false
        }

        return true
    }
}
