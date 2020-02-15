import PromiseKit
import FirebaseFirestore.FIRCollectionReference

protocol UserProtocol {
    func createUser(id: String) -> Promise<Void>
    func getUser(withId id: String) -> Promise<User>
    func getGenders() -> Promise<[String:String]>
    func getSalutations() -> Promise<[String:String]>
    func getCertifications() -> Promise<[String:Certification]>
    func getCurrentUser() -> Promise<User>
}
