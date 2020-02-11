import Foundation

struct Answer {
    var createdBy: User?
    var modifiedDate = Date()
    var text = ""
    var media = [Media]()
    var upvotes = 0
    var downvotes = 0
}
