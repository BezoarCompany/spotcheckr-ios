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
        Analytics.setAnalyticsCollectionEnabled(enabled)
        SwiftyPlistManager.shared.save(enabled,
                                       forKey: "analyticsCollectionEnabled",
                                       toPlistWithName: "Preferences") { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func getCollectionEnabled() -> Bool {
        guard let result = SwiftyPlistManager.shared.fetchValue(for: "analyticsCollectionEnabled", fromPlistWithName: "Preferences") else { return false }
        return result as? Bool ?? false
    }
}
