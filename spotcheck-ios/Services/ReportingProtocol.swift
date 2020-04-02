import PromiseKit

protocol ReportingProtocol {
    func getReportOptions() -> Promise<[Report]>
}
