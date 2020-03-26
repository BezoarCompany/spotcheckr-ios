import Foundation

class User {
    var id: String?
    var username: String?
    var profilePicturePath: String?
    var information: Identity?
    var measurement: BodyMeasurement?
    var contactInformation: Contact?
    var exercisePosts = [ExercisePost]()
    
    init(id: String?) {
        self.id = id
    }
}
