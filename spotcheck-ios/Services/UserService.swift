import FirebaseFirestore
import PromiseKit

class UserService: UserProtocol {
    private let userCollection = "users"
    
    func createUser(id: String) -> Promise<Void> {
        return Promise { promise in
            Firestore.firestore().collection(userCollection).addDocument(data: [
                "id": id
            ]){ error in
                return error != nil ? promise.reject(error!) : promise.fulfill_()
            }
        }
    }
}
