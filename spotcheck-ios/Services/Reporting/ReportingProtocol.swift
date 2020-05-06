import PromiseKit

protocol ReportingProtocol {
    func getReportTypes() -> Promise<[ReportType]>
    func submitReport(contentId: GenericID?, details: Report) -> Promise<Void>
}
