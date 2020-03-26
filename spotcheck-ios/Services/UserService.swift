import FirebaseFirestore
import FirebaseFirestore.FIRCollectionReference
import FirebaseFirestore.FIRTimestamp
import FirebaseAuth
import PromiseKit
import Foundation

class UserService: UserProtocol {
    private let userCollection = "users"
    private let genderCollection = "genders"
    private let userTypeCollection = "user-types"
    private let certificationCollection = "certifications"
    private let salutationCollection = "salutations"
    
    private let cache = Cache<String, User>() // (userID<String>: User)
    private let firebaseMapCache = Cache<String, Any>()
    
    func createUser(user: User) -> Promise<Void> {
        return Promise { promise in
            firstly {
                getUserTypes()
            }.done { userTypes in
                let userType: String = user is Trainer ? "Trainer" : "User"
                let userTypePath = (userTypes as NSDictionary).allKeys(for: userType)[0] as! String
                let userTypeDocRef = Firestore.firestore().document("\(userTypePath)")
                
                Firestore.firestore().collection(self.userCollection).document(user.id!).setData([
                    "id": user.id!,
                    "type": userTypeDocRef
                ]){ error in
                    return error != nil ? promise.reject(error!) : promise.fulfill_()
                }
            }.catch { error in
                return promise.reject(error)
            }
        }
    }
    
    func getUser(withId id: String) -> Promise<User> {
        return Promise { promise in
            if let user = cache[id] {
                //print("Cache HIT!!! \(user.id)=> \(user.username)")
                return promise.fulfill(user)
            }

            let docRef = Firestore.firestore().collection(userCollection).document(id)
            docRef.getDocument { doc, error in
                guard error == nil, let doc = doc, doc.exists else {
                    return promise.reject(error!)
                }
                
                let data = doc.data()
                let userId = data?.keys.contains("id") != nil ? data?["id"] as! String : doc.documentID
                var salutations: [String:String] = [:]
                var genders: [String:String] = [:]
                var userTypes: [String:String] = [:]
                var userCertifications = [Certification]()
                
                firstly {
                    when(fulfilled: self.getSalutations(),
                                    self.getGenders(),
                                    self.getUserTypes(),
                                    self.getCertifications(forUserWithId: userId))
                }.done { salutationsResult,
                         gendersResult,
                         userTypesResult,
                         userCertificationsResult in
                    salutations = salutationsResult
                    genders = gendersResult
                    userTypes = userTypesResult
                    userCertifications = userCertificationsResult
                }.catch { error in
                    return promise.reject(error)
                }.finally {
                    var user: User
                    
                    let userIsTrainer = data?.keys.contains("type") != nil && userTypes[(data?["type"] as! DocumentReference).path] == "Trainer"
                    
                    user = userIsTrainer ? Trainer(id: userId) : User(id: userId)
                    user.username = (data?.keys.contains("username"))! ? data?["username"] as! String : ""
                    user.profilePicturePath = (data?.keys.contains("profile-picture-path"))! ?  data?["profile-picture-path"] as? String : nil
                    user.information = Identity(
                        salutation: (data?.keys.contains("salutation"))! ? salutations[(data?["salutation"] as! DocumentReference).path]! : "",
                        firstName: (data?.keys.contains("first-name"))! ? data?["first-name"] as! String : "",
                        middleName: (data?.keys.contains("middle-name"))! ? data?["middle-name"] as! String : "",
                        lastName: (data?.keys.contains("last-name"))! ? data?["last-name"] as! String : "",
                        gender: (data?.keys.contains("gender"))! ? genders[(data?["gender"] as! DocumentReference).path]! : "",
                        birthDate: (data?.keys.contains("birthdate"))! ? (data?["birthdate"] as! Timestamp).dateValue() : nil
                    )
                    user.measurement = BodyMeasurement(
                        height: (data?.keys.contains("height"))! ? Int(data?["height"] as! String) : 0,
                        weight: (data?.keys.contains("weight"))! ? Int(data?["weight"] as! String) : 0
                    )
                    
                    if userIsTrainer {
                        let trainer = user as! Trainer

                        trainer.website = (data?.keys.contains("website"))! ? URL(string: data?["website"] as! String) : nil
                        trainer.occupationTitle = (data?.keys.contains("occupation-title"))! ? data?["occupation-title"] as! String : ""
                        trainer.occupationCompany = (data?.keys.contains("occupation-company"))! ? data?["occupation-company"] as! String : ""
                        trainer.certifications = userCertifications
                    }
                    //store in cache
                    self.cache[user.id!] = user
                    
                    return promise.fulfill(user)
                }
                
                //TODO: Get more complex information about the user.
                                
            }
        }
    }
    
    func getCertifications(forUserWithId id: String) -> Promise<[Certification]> {
        return Promise { promise in
            var certifications: [String:Certification] = [:]
            
            firstly {
                self.getCertifications()
            }.done { certificationsResult in
                certifications = certificationsResult
            }.catch { error in
                return promise.reject(error)
            }.finally {
                var userCertifications = [Certification]()
                let certificationsRef = Firestore.firestore().collection("\(self.userCollection)/\(id)/\(self.certificationCollection)")
                certificationsRef.getDocuments { (certificationsSnapshot, error) in
                    if let error = error {
                        return promise.reject(error)
                    }
                    
                    for certification in certificationsSnapshot!.documents {
                        userCertifications.append(certifications[(certification["certification"] as! DocumentReference).path]!)
                    }
                
                    return promise.fulfill(userCertifications)
                }
            }
        }
    }
    
    func getCurrentUser() -> Promise<User> {
        return Promise { promise in
            
            let userId = Auth.auth().currentUser?.uid
            
            if let user = cache[userId!] {
                return promise.fulfill(user)
            }
            firstly {
                self.getUser(withId: userId!)
            }.done { user in
                self.cache[user.id!] = user
                return promise.fulfill(user)
            }.catch { error in
                return promise.reject(error)
            }
        }
    }
    
    
    func getUserTypes() -> Promise<[String: String]>{
        return Promise { promise in
            if let userTypes = firebaseMapCache["user-types"] as? [String:String] {
                return promise.fulfill(userTypes)
            }
            
            Firestore.firestore().collection(userTypeCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }
                
                var userTypes:[String:String] = [:]
                for document in querySnapshot!.documents {
                    userTypes[document.reference.path] = document.data()["name"] as? String
                }
                
                self.firebaseMapCache.insert(userTypes, forKey: "user-types")
                return promise.fulfill(userTypes)
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
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch { error
            throw error
        }
    }
}
