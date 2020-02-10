import PromiseKit

protocol UserProtocol {
    func createUser(id: String) -> Promise<Void>
}
