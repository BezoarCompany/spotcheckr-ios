import PromiseKit

protocol SystemProtocol {
    func getConfiguration() -> Promise<Configuration>
    func getPreferences() -> Preferences
    func savePreference(value: Any, key: String, success: () -> Void)
}
