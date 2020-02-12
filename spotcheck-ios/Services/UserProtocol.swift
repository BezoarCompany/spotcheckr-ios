import PromiseKit

protocol UserProtocol {
    func createUser(id: String) -> Promise<Void>
    func getUser(withId id: String) -> Promise<User>
    func getCurrentUser() -> Promise<User>
}
