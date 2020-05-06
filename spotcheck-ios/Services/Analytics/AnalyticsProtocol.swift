protocol AnalyticsProtocol {
    func logEvent(event: AnalyticsEvent) throws
    func getCollectionEnabled() -> Bool
    func setCollectionEnabled(_ enabled: Bool) throws
    func getPerformanceMonitoringEnabled() -> Bool
    func setPerformanceMonitoringEnabled(_ enabled: Bool) throws
}
