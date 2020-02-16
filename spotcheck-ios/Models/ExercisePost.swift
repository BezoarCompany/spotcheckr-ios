import Foundation

struct ExercisePost {
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var createdBy: User?
    var dateCreated: Date?
    var dateModified: Date?
    var metrics = Metrics()
    var answers = [Answer]()
    var media = [Media]()
    var exercises = [Exercise]()
}
