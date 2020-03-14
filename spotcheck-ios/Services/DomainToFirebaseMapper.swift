import Firebase
// Responsible for mapping from domain model to firebase model until a better method is found.
class DomainToFirebaseMapper {
    static func mapAnswer(from: Answer) -> [String:Any] {
        var firebaseAnswer = [String:Any]()
        firebaseAnswer["created-by"] = from.createdBy?.id
        firebaseAnswer["created-date"] = from.dateCreated
        firebaseAnswer["modified-date"] = from.dateModified
        firebaseAnswer["text"] = from.text
        firebaseAnswer["exercise-post"] = from.exercisePost?.id
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
        return firebaseExercisePost
    }
    
    static func mapExercise(exercise: Exercise) -> [String:Any] {
        var firebaseExercise = [String:Any]()
        firebaseExercise["id"] = exercise.id
        firebaseExercise["name"] = exercise.name
        return firebaseExercise
    }
}
