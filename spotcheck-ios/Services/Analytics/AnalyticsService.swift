import FirebasePerformance
import FirebaseAnalytics
import PromiseKit
import SwiftyPlistManager

class AnalyticsService: AnalyticsProtocol {
    private let maxLength = 40
    private let maxParametersCount = 25

    func logEvent(event: AnalyticsEvent) throws {
        //TODO: Make sure event name is not in the list of reserved firebase names.
        //https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#logevent_:parameters:
        if event.name.count == 0 || event.name.count > maxLength {
            throw String("Event name must be between 1 and \(maxLength) characters.")
        }
        //TODO: add check to make sure that the event starts with a letter. Throw an error if it doesn't.
        if event.parameters?.count ?? 0 > maxParametersCount {
            throw String("There cannot be more than \(maxParametersCount) parameters.")
        }
        Analytics.logEvent(event.name, parameters: event.parameters)
    }

    func setCollectionEnabled(_ enabled: Bool) throws {
        Services.systemService.savePreference(value: enabled, key: "analyticsCollectionEnabled", success: {
           Analytics.setAnalyticsCollectionEnabled(enabled)
        })
    }

    func setPerformanceMonitoringEnabled(_ enabled: Bool) throws {
        Services.systemService.savePreference(value: enabled, key: "performanceMonitoringCollectionEnabled", success: {
            Performance.sharedInstance().isDataCollectionEnabled = enabled
            Performance.sharedInstance().isInstrumentationEnabled = enabled
        })
    }
}
