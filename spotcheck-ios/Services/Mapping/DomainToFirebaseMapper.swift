import Firebase

// Responsible for mapping from domain model to firebase model until a better method is found.
class DomainToFirebaseMapper {
    static func mapAnswer(from: Answer) -> [String: Any] {
        var firebaseAnswer = [String: Any]()
        firebaseAnswer["id"] = from.id?.value
        firebaseAnswer["created-by"] = from.createdBy?.id?.value
        firebaseAnswer["created-date"] = from.dateCreated
        firebaseAnswer["modified-date"] = from.dateModified
        firebaseAnswer["text"] = from.text
        firebaseAnswer["exercise-post"] = from.exercisePostId?.value
        firebaseAnswer["upvote-count"] = from.metrics?.upvotes ?? 0
        firebaseAnswer["downvote-count"] = from.metrics?.downvotes ?? 0
        return firebaseAnswer
    }

    static func mapExercisePost(post: ExercisePost) -> [String: Any] {
        var firebaseExercisePost = [String: Any]()
        firebaseExercisePost["id"] = post.id?.value
        firebaseExercisePost["created-by"] = post.createdBy?.id?.value
        firebaseExercisePost["created-date"] = post.dateCreated
        firebaseExercisePost["title"] = post.title
        firebaseExercisePost["description"] = post.description
        firebaseExercisePost["modified-date"] = post.dateModified
        firebaseExercisePost["image-path"] = post.imagePath
        firebaseExercisePost["video-path"] = post.videoPath
        firebaseExercisePost["answers-count"] = post.answersCount
        firebaseExercisePost["upvote-count"] = post.metrics.upvotes
        firebaseExercisePost["downvote-count"] = post.metrics.downvotes

        return firebaseExercisePost
    }

    static func mapExercise(exercise: Exercise) -> [String: Any] {
        var firebaseExercise = [String: Any]()
        firebaseExercise["id"] = exercise.id
        firebaseExercise["name"] = exercise.name
        return firebaseExercise
    }

    static func mapUser(user: User) -> [String: Any] {
        //TODO: Map more properties
        var firebaseUser = [String: Any]()
        firebaseUser["first-name"] = user.information?.firstName
        firebaseUser["last-name"] = user.information?.lastName
        firebaseUser["is-anonymous"] = user.isAnonymous
        firebaseUser["date-created"] = user.dateCreated
        return firebaseUser
    }

    static func mapReport(contentId: GenericID?, details: Report) -> [String: Any] {
        var firebaseReport = [String: Any]()
        firebaseReport["type"] = Firestore.firestore().document("/\(CollectionConstants.reportTypesCollection)/\(details.reportType!.id!)")
        firebaseReport["content-id"] = Firestore.firestore().document("/\(CollectionConstants.postsCollection)/\(contentId!.value)")
        firebaseReport["content-type"] = details.contentType?.rawValue ?? ""
        firebaseReport["description"] = details.description
        firebaseReport["created-by"] = Firestore.firestore().document("/\(CollectionConstants.userCollection)/\(details.createdBy!.id!.value)")
        firebaseReport["created-date"] = details.createdDate ?? Date()
        return firebaseReport
    }
}
