import PromiseKit

protocol ReportingProtocol {
    func getReportTypes() -> Promise<[ReportType]>
    func submitReport(postId: String?, details: Report) -> Promise<Void>
}
