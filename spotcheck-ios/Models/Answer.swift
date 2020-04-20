import Foundation

struct Answer {
    var id: AnswerID?
    var createdBy: User?
    var dateCreated: Date?
    var dateModified: Date?
    var exercisePostId: ExercisePostID?
    var text = ""
    var media = [Media]()
    var metrics: Metrics?
}
