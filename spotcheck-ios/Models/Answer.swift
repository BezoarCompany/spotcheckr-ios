import Foundation

struct Answer {
    var id: String?
    var createdBy: User?
    var dateCreated: Date?
    var dateModified: Date?
    var exercisePostId: String?
    var text = ""
    var media = [Media]()
    var metrics: Metrics?
}
