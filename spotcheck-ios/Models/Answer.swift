import Foundation

class Answer {
    var id: AnswerID?
    var createdBy: User?
    var dateCreated: Date?
    var dateModified: Date?
    var exercisePostId: ExercisePostID?
    var text = ""
    var media = [Media]()
    var metrics: Metrics?

    init(id: AnswerID? = nil,
         createdBy: User? = nil,
         dateCreated: Date? = nil,
         dateModified: Date? = nil,
         exercisePostId: ExercisePostID? = nil,
         text: String = "",
         media: [Media] = [Media](),
         metrics: Metrics? = nil) {
        self.id = id
        self.createdBy = createdBy
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.exercisePostId = exercisePostId
        self.text = text
        self.media = media
        self.metrics = metrics
    }
}
