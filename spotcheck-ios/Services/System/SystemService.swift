import FirebaseFirestore
import PromiseKit
import SwiftyPlistManager

class SystemService: SystemProtocol {
     private let preferencesPlistFileName = "Preferences"

    //TODO: Call at application start-up to check that the user has a minimum app level, otherwise show an error message directing
    //them to the app store to update the app. Doesn't work yet because we need a disk cache as well since NSCache isn't available during that lifecycle.
    func getConfiguration() -> Promise<Configuration> {
        return Promise { promise in
            if let config = CacheManager.stringCache["configuration"] as? Configuration {
                return promise.fulfill(config)
            }

            let configurationDocRef = Firestore.firestore().collection(CollectionConstants.systemCollection).document("configuration")
            configurationDocRef.getDocument { (snapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }

                let config = FirebaseToDomainMapper.mapConfiguration(data: snapshot!.data()!)
                CacheManager.stringCache.insert(config, forKey: "configuration")
                return promise.fulfill(config)
            }
        }
    }

    func getPreferences() -> Preferences {
        let analyticsCollectionEnabled = SwiftyPlistManager.shared.fetchValue(for: "analyticsCollectionEnabled",
                                                                              fromPlistWithName: preferencesPlistFileName) as? Bool
        let performanceMonitoringCollectionEnabled = SwiftyPlistManager.shared.fetchValue(for: "performanceMonitoringCollectionEnabled",
                                                                                        fromPlistWithName: preferencesPlistFileName) as? Bool
        let loggingEnabled = SwiftyPlistManager.shared.fetchValue(for: "loggingEnabled",
                                                                 fromPlistWithName: preferencesPlistFileName) as? Bool

        return Preferences(loggingEnabled: loggingEnabled,
                           analyticsCollectionEnabled: analyticsCollectionEnabled,
                           performanceMonitoringCollectionEnabled: performanceMonitoringCollectionEnabled)
    }

    func savePreference(value: Any, key: String, success: () -> Void) {
        SwiftyPlistManager.shared.save(value,
                                       forKey: key,
                                       toPlistWithName: preferencesPlistFileName) { error in
                                        if error == nil {
                                            success()
                                        } else {
                                            LogManager.error(error?.localizedDescription ?? "")
                                        }
        }
    }
}
