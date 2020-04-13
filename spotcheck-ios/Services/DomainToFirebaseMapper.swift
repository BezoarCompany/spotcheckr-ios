import Firebase

// Responsible for mapping from domain model to firebase model until a better method is found.
class DomainToFirebaseMapper {
    static func mapAnswer(from: Answer) -> [String:Any] {
        var firebaseAnswer = [String:Any]()
        firebaseAnswer["id"] = from.id
        firebaseAnswer["created-by"] = from.createdBy?.id
        firebaseAnswer["created-date"] = from.dateCreated
        firebaseAnswer["modified-date"] = from.dateModified
        firebaseAnswer["text"] = from.text
        firebaseAnswer["exercise-post"] = from.exercisePostId
        firebaseAnswer["upvote-count"] = from.metrics?.upvotes ?? 0
        firebaseAnswer["downvote-count"] = from.metrics?.downvotes ?? 0
        return firebaseAnswer
    }
    
    static func mapExercisePost(post: ExercisePost) -> [String:Any] {
        var firebaseExercisePost = [String:Any]()
        firebaseExercisePost["id"] = post.id
        firebaseExercisePost["created-by"] = post.createdBy?.id
        firebaseExercisePost["created-date"] = post.dateCreated
        firebaseExercisePost["title"] = post.title
        firebaseExercisePost["description"] = post.description
        firebaseExercisePost["modified-date"] = post.dateModified
        firebaseExercisePost["image-path"] = post.imagePath
        firebaseExercisePost["answers-count"] = post.answersCount
        firebaseExercisePost["upvote-count"] = post.metrics.upvotes
        firebaseExercisePost["downvote-count"] = post.metrics.downvotes
        
        return firebaseExercisePost
    }
    
    static func mapExercise(exercise: Exercise) -> [String:Any] {
        var firebaseExercise = [String:Any]()
        firebaseExercise["id"] = exercise.id
        firebaseExercise["name"] = exercise.name
        return firebaseExercise
    }
    
    static func mapUser(user: User) -> [String:Any] {
        //TODO: Map more properties
        var firebaseUser = [String:Any]()
        firebaseUser["first-name"] = user.information?.firstName
        firebaseUser["last-name"] = user.information?.lastName
        return firebaseUser
    }
    
    static func mapReport(postId: String?, details: Report) -> [String:Any] {
        var firebaseReport = [String:Any]()
        firebaseReport["type"] = Firestore.firestore().document("/\(CollectionConstants.reportTypesCollection)/\(details.reportType!.id!)")
        if let postId = postId {
            firebaseReport["exercise-post"] = Firestore.firestore().document("/\(CollectionConstants.postsCollection)/\(postId)")
        }
        firebaseReport["description"] = details.description
        firebaseReport["created-by"] = Firestore.firestore().document("/\(CollectionConstants.userCollection)/\(details.createdBy!.id!)")
        firebaseReport["created-date"] = details.createdDate ?? Date()
        return firebaseReport
    }
}
