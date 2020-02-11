import FirebaseFirestore
import PromiseKit

class UserService: UserProtocol {
    private let userCollection = "users"
    
    func createUser(id: String) -> Promise<Void> {
        return Promise { promise in
            Firestore.firestore().collection(userCollection).document(id).setData([
                "id": id
            ]){ error in
                return error != nil ? promise.reject(error!) : promise.fulfill_()
            }
        }
    }
    
    func getUser(withId id: String) -> Promise<User> {
        return Promise { promise in
            let docRef = Firestore.firestore().collection(userCollection).document(id)
            docRef.getDocument { doc, error in
                guard error == nil, let doc = doc, doc.exists else {
                    return promise.reject(error!)
                }
                let user = User(id: doc.data()?["id"] as! String)
                let data = doc.data()
                //TODO: Replace .contains check here with an extension method with something that will take the key, type to downcast, and default value and just return that instead of writing all this boilerplate.
                user.information = Identity(firstName: (data?.keys.contains("first-name"))! ? data?["first-name"] as! String : "",
                                           middleName: (data?.keys.contains("middle-name"))! ? data?["middle-name"] as! String : "",
                                           lastName: (data?.keys.contains("last-name"))! ? data?["last-name"] as! String : "")
                //TODO: Get more complex information about the user.
                return promise.fulfill(user)
            }
        }
    }
}
