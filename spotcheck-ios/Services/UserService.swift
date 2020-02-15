import FirebaseFirestore
import FirebaseFirestore.FIRCollectionReference
import FirebaseAuth
import PromiseKit
import Foundation

class UserService: UserProtocol {
    private let userCollection = "users"
    private let genderCollection = "genders"
    private let certificationCollection = "certifications"
    private let salutationCollection = "salutations"
    
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
                                           lastName: (data?.keys.contains("last-name"))! ? data?["last-name"] as! String : "",
                                           gender: )
                //TODO: Get more complex information about the user.
                //TODO: Store in the cache afterwards.
                return promise.fulfill(user)
            }
        }
    }
    
    func getCurrentUser() -> Promise<User> {
        return Promise { promise in
            //TODO: Fetch from cache instead and store in there too.
            let userId = Auth.auth().currentUser?.uid
            
            firstly {
                self.getUser(withId: userId!)
            }.done { user in
                return promise.fulfill(user)
            }.catch { error in
                return promise.reject(error)
            }
        }
    }
    
    func getGenders() -> Promise<[String:String]> {
        return Promise { promise in
            Firestore.firestore().collection(genderCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }
                
                var genders:[String:String] = [:]
                for document in querySnapshot!.documents {
                    genders[document.reference.path] = document.data()["name"] as? String
                }
                
                return promise.fulfill(genders)
            }
        }
    }
    
    func getSalutations() -> Promise<[String:String]> {
        return Promise { promise in
            Firestore.firestore().collection(salutationCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }
                
                var salutations:[String:String] = [:]
                for document in querySnapshot!.documents {
                    salutations[document.reference.path] = document.data()["name"] as? String
                }
                
                return promise.fulfill(salutations)
            }
        }
    }
    
    func getCertifications() -> Promise<[String:Certification]> {
        return Promise { promise in
            Firestore.firestore().collection(certificationCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }
                
                var certifications:[String:Certification] = [:]
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let certification = Certification(name: (data["name"] as? String)!,
                                                      code: (data["code"] as? String)!,
                                                      issuer: Organization(name: (data["organization"] as? String)!))
                    certifications[document.reference.path] = certification
                }
                
                return promise.fulfill(certifications)
            }
        }
    }
    
}
