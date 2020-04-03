import Foundation

struct Report {
    var reportType: ReportType?
    var description: String?
    var createdBy: User?
    var createdDate: Date? = Date()
}
