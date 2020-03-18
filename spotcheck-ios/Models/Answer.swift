import Foundation

struct Answer {
    var id: String?
    var createdBy: User?
    var dateCreated: Date?
    var dateModified: Date?
    var exercisePost: ExercisePost?
    var text = ""
    var media = [Media]()
    var metrics: Metrics?
}
