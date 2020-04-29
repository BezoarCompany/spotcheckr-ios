protocol AnalyticsProtocol {
    func logEvent(event: AnalyticsEvent) throws
    func getCollectionEnabled() -> Bool
    func setCollectionEnabled(_ enabled: Bool) throws
}
