import Foundation

class User {
    var id: UserID?
    var username: String?
    var profilePicturePath: String?
    var information: Identity?
    var measurement: BodyMeasurement?
    var contactInformation: Contact?
    var exercisePosts = [ExercisePost]()
    var isAnonymous = false
    var dateCreated: Date?
    var answerVotes = [AnswerID:Int]()
    var exercisePostVotes = [ExercisePostID:Int]()
    
    init(id: UserID) {
        self.id = id
    }
}
