import PromiseKit
import FirebaseFirestore.FIRCollectionReference

protocol UserProtocol {
    func createUser(user: User) -> Promise<Void>
    
    func getUser(withId id: String) -> Promise<User>
    func getCertifications(forUserWithId id: String) -> Promise<[Certification]>
    func getUserTypes() -> Promise<[String:String]>
    func getGenders() -> Promise<[String:String]>
    func getSalutations() -> Promise<[String:String]>
    func getCertifications() -> Promise<[String:Certification]>
    func getCurrentUser() -> Promise<User>
    
    func updateUser(_ user: User) -> Promise<Void>
    
    func signOut() throws -> Void
}
