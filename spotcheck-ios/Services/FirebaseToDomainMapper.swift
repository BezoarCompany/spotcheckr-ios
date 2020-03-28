import Firebase
// Responsible for mapping from Firebase model to domain model until a better method is found.
class FirebaseToDomainMapper {
    static func mapAnswer(fromData data:[String:Any],
                           metrics: Metrics,
                           createdBy: User) -> Answer {
        var answer = Answer()
        answer.id = data.keys.contains("id") ? data["id"] as? String : nil
        answer.exercisePostId = data.keys.contains("exercise-post") ? data["exercise-post"] as? String : nil
        answer.text = data.keys.contains("text") ? data["text"] as! String : ""
        answer.metrics = metrics
        answer.dateCreated = data.keys.contains("created-date") ? (data["created-date"] as! Timestamp).dateValue() : nil
        answer.dateModified = data.keys.contains("modified-date") ? (data["modified-date"] as! Timestamp).dateValue() : nil
        answer.createdBy = createdBy
        return answer
    }
    
    static func mapExercisePost(fromData data:[String: Any],
                                 metrics: Metrics,
                                 exercises: [Exercise],
                                 answers: [Answer] = [Answer]()) -> ExercisePost {
        var post = ExercisePost()
        post.id = data.keys.contains("id") ? data["id"] as! String : ""
        post.title = data.keys.contains("title") ? data["title"] as! String : ""
        post.description = data.keys.contains("description") ? data["description"] as! String : ""
        post.dateCreated = data.keys.contains("created-date") ? (data["created-date"] as! Timestamp).dateValue() : nil
        post.dateModified = data.keys.contains("modified-date") ? (data["modified-date"] as! Timestamp).dateValue() : nil
        post.metrics = metrics
        post.exercises = exercises
        post.answers = answers
        return post
    }
    
}
