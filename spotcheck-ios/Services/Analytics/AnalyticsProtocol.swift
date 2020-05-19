protocol AnalyticsProtocol {
    func logEvent(event: AnalyticsEvent) throws
    func setCollectionEnabled(_ enabled: Bool) throws
    func setPerformanceMonitoringEnabled(_ enabled: Bool) throws
}
