import Foundation

class ExercisePost {
    var id: ExercisePostID?
    var title: String = ""
    var description: String = ""
    var createdBy: User?
    var dateCreated: Date?
    var dateModified: Date?
    var metrics = Metrics()
    var media = [Media]()
    var exercises = [Exercise]()
    var answersCount: Int = 0
    var imagePath: String?
    var videoPath: String?

    init(id: String = "", title: String = "", description: String = "",
         createdBy: User? = nil, dateCreated: Date? = nil, dateModified: Date? = nil,
         metrics: Metrics = Metrics(), answers: [Answer] = [], media: [Media] = [],
         exercises: [Exercise] = [], answersCount: Int = 0, imagePath: String? = nil, videoPath: String? = nil) {

        self.id = ExercisePostID(id)
        self.title = title
        self.description = description

        self.createdBy = createdBy
        self.dateCreated = dateCreated
        self.dateModified = dateModified

        self.metrics = metrics
        self.media = media

        self.exercises = exercises
        self.answersCount = answersCount
        self.imagePath = imagePath
        self.videoPath = imagePath
    }
}
