import Firebase
// Responsible for mapping from Firebase model to domain model until a better method is found.
class FirebaseToDomainMapper {
    static func mapAnswer(fromData data: [String: Any],
                           metrics: Metrics,
                           createdBy: User) -> Answer {
        var answer = Answer()
        answer.id = data.keys.contains("id") ? AnswerID(data["id"] as! String) : nil
        answer.exercisePostId = data.keys.contains("exercise-post") ? ExercisePostID(data["exercise-post"] as! String) : nil
        answer.text = data.keys.contains("text") ? data["text"] as! String : ""
        answer.metrics = metrics
        answer.dateCreated = data.keys.contains("created-date") ? (data["created-date"] as! Timestamp).dateValue() : nil
        answer.dateModified = data.keys.contains("modified-date") ? (data["modified-date"] as! Timestamp).dateValue() : nil
        answer.createdBy = createdBy
        return answer
    }

    static func mapExercisePost(fromData data: [String: Any],
                                 metrics: Metrics,
                                 exercises: [Exercise]) -> ExercisePost {
        let post = ExercisePost()
        post.id = data.keys.contains("id") ? ExercisePostID(data["id"] as! String) : nil
        post.title = data.keys.contains("title") ? data["title"] as! String : ""
        post.description = data.keys.contains("description") ? data["description"] as! String : ""
        post.dateCreated = data.keys.contains("created-date") ? (data["created-date"] as! Timestamp).dateValue() : nil
        post.dateModified = data.keys.contains("modified-date") ? (data["modified-date"] as! Timestamp).dateValue() : nil
        post.imagePath = data.keys.contains("image-path") ? data["image-path"] as? String : nil
        post.videoPath = data.keys.contains("video-path") ? data["video-path"] as? String : nil
        post.metrics = metrics
        post.exercises = exercises
        post.answersCount = data.keys.contains("answers-count") ? data["answers-count"] as! Int : 0

        return post
    }

    static func mapReportType(id: String?, data: [String: Any]) -> ReportType {
        let reportType = ReportType(id: id, name: data.keys.contains("name") ? data["name"] as? String : nil)
        return reportType
    }

    static func mapConfiguration(data: [String: Any]) -> Configuration {
        let minimumAppVersion = data.keys.contains("minimum-app-version") ? data["minimum-app-version"] as! String : "0.0.0"
        let major = minimumAppVersion.stringAt(0)
        let minor = minimumAppVersion.stringAt(2)
        let patch = minimumAppVersion.stringAt(4)
        let config = Configuration(minimumAppVersion: SemanticVersion(major: major, minor: minor, patch: patch),
                                   maxImageUploadSize: data.keys.contains("max-image-upload-size-in-mb") ? (data["max-image-upload-size-in-mb"] as? Int ?? 10) : 10)
        return config
    }

    static func mapUser(userId: UserID,
                       genders: [String: String],
                       userTypes: [String: String],
                       data: [String: Any]?,
                       mapVoteDetails: Bool = false) -> User {
        let user: User
        let userIsTrainer = data?.keys.contains("type") != nil && userTypes[(data?["type"] as! DocumentReference).path] == "Trainer"

        user = userIsTrainer ? Trainer(id: userId) : User(id: userId)
        user.username = (data?.keys.contains("username"))! ? data?["username"] as! String : ""
        user.profilePicturePath = (data?.keys.contains("profile-picture-path"))! ?  data?["profile-picture-path"] as? String : nil
        user.information = Identity(
            firstName: (data?.keys.contains("first-name"))! ? data?["first-name"] as! String : "",
            middleName: (data?.keys.contains("middle-name"))! ? data?["middle-name"] as! String : "",
            lastName: (data?.keys.contains("last-name"))! ? data?["last-name"] as! String : "",
            gender: (data?.keys.contains("gender"))! ? genders[(data?["gender"] as! DocumentReference).path]! : "",
            birthDate: (data?.keys.contains("birthdate"))! ? (data?["birthdate"] as! Timestamp).dateValue() : nil
        )
        user.measurement = BodyMeasurement(
            height: (data?.keys.contains("height"))! ? Int(data?["height"] as! String) : 0,
            weight: (data?.keys.contains("weight"))! ? Int(data?["weight"] as! String) : 0
        )

        if mapVoteDetails {
            let exercisePostVotes = (data?.keys.contains("exercise-post-votes"))! ? data?["exercise-post-votes"] as? [String: Int] : [String: Int]()
            for (key, value) in exercisePostVotes! {
                user.exercisePostVotes.add([ExercisePostID(key): VoteDirection(rawValue: value)!])
            }

            let answerVotes = (data?.keys.contains("answer-votes"))! ? data?["answer-votes"] as? [String: Int] : [String: Int]()
            for (key, value) in answerVotes! {
                user.answerVotes.add([AnswerID(key): VoteDirection(rawValue: value)!])
            }
        }

        if userIsTrainer {
            let trainer = user as! Trainer

            trainer.website = (data?.keys.contains("website"))! ? URL(string: data?["website"] as! String) : nil
            trainer.occupationTitle = (data?.keys.contains("occupation-title"))! ? data?["occupation-title"] as! String : ""
            trainer.occupationCompany = (data?.keys.contains("occupation-company"))! ? data?["occupation-company"] as! String : ""
        }

        return user
    }
}
