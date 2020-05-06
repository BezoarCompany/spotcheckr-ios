import PromiseKit

protocol SystemProtocol {
    func getConfiguration() -> Promise<Configuration>
}
