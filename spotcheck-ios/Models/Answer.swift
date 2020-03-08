import Foundation

struct Answer {
    var createdBy: User?
    var dateCreated: Date?
    var dateModified: Date?
    var exercisePost: ExercisePost?
    var text = ""
    var media = [Media]()
    var upvotes = 0
    var downvotes = 0
}
