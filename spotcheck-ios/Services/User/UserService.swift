import FirebaseFirestore
import FirebaseFirestore.FIRCollectionReference
import FirebaseFirestore.FIRTimestamp
import FirebaseAuth
import PromiseKit
import Foundation

class UserService: UserProtocol {
    func createUser(user: User) -> Promise<Void> {
        return Promise { promise in
            firstly {
                getUserTypes()
            }.done { userTypes in
                let userType: String = user is Trainer ? "Trainer" : "User"
                let userTypePath = (userTypes as NSDictionary).allKeys(for: userType)[0] as! String
                let userTypeDocRef = Firestore.firestore().document("\(userTypePath)")

                Firestore.firestore().collection(CollectionConstants.userCollection).document(user.id!.value).setData([
                    "id": user.id!.value,
                    "type": userTypeDocRef,
                    "is-anonymous": user.isAnonymous,
                    "date-created": user.dateCreated ?? Date()
                ]) { error in
                    return error != nil ? promise.reject(error!) : promise.fulfill_()
                }
            }.catch { error in
                return promise.reject(error)
            }
        }
    }

    func getUser(withId id: UserID, includeVoteDetails: Bool = false) -> Promise<User> {
        return Promise { promise in
            if let user = CacheManager.userCache[id] {
                return promise.fulfill(user)
            }

            let docRef = Firestore.firestore().collection(CollectionConstants.userCollection).document(id.value)
            docRef.getDocument { doc, error in
                guard error == nil, let doc = doc, doc.exists else {
                    return promise.reject(error!)
                }

                let data = doc.data()
                let userId = UserID(doc.documentID)

                firstly {
                    when(fulfilled: self.getGenders(), self.getUserTypes())
                }.done { gendersResult, userTypesResult in
                    let user = FirebaseToDomainMapper.mapUser(userId: userId,
                                                              genders: gendersResult,
                                                              userTypes: userTypesResult,
                                                              data: data,
                                                              mapVoteDetails: includeVoteDetails)
                    CacheManager.userCache[user.id!] = user
                    return promise.fulfill(user)
                }.catch { error in
                    return promise.reject(error)
                }
            }
        }
    }

    func getCertifications(forUserWithId id: UserID) -> Promise<[Certification]> {
        return Promise { promise in
            var certifications: [String: Certification] = [:]

            firstly {
                self.getCertifications()
            }.done { certificationsResult in
                certifications = certificationsResult
            }.catch { error in
                return promise.reject(error)
            }.finally {
                var userCertifications = [Certification]()
                let certificationsRef = Firestore.firestore().collection("\(CollectionConstants.userCollection)/\(id)/\(CollectionConstants.certificationCollection)")
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

            let userId = UserID(Auth.auth().currentUser!.uid)

            if let user = CacheManager.userCache[userId] {
                return promise.fulfill(user)
            }
            firstly {
                self.getUser(withId: userId, includeVoteDetails: true)
            }.done { user in
                CacheManager.userCache[user.id!] = user
                return promise.fulfill(user)
            }.catch { error in
                return promise.reject(error)
            }
        }
    }

    func getUserTypes() -> Promise<[String: String]> {
        return Promise { promise in
            if let userTypes = CacheManager.stringCache["user-types"] as? [String: String] {
                return promise.fulfill(userTypes)
            }

            Firestore.firestore().collection(CollectionConstants.userTypeCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }

                var userTypes: [String: String] = [:]
                for document in querySnapshot!.documents {
                    userTypes[document.reference.path] = document.data()["name"] as? String
                }

                CacheManager.stringCache.insert(userTypes, forKey: "user-types")
                return promise.fulfill(userTypes)
            }
        }
    }

    func getGenders() -> Promise<[String: String]> {
        return Promise { promise in
            Firestore.firestore().collection(CollectionConstants.genderCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }

                var genders: [String: String] = [:]
                for document in querySnapshot!.documents {
                    genders[document.reference.path] = document.data()["name"] as? String
                }

                return promise.fulfill(genders)
            }
        }
    }

    func getSalutations() -> Promise<[String: String]> {
        return Promise { promise in
            Firestore.firestore().collection(CollectionConstants.salutationCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }

                var salutations: [String: String] = [:]
                for document in querySnapshot!.documents {
                    salutations[document.reference.path] = document.data()["name"] as? String
                }

                return promise.fulfill(salutations)
            }
        }
    }

    func getCertifications() -> Promise<[String: Certification]> {
        return Promise { promise in
            Firestore.firestore().collection(CollectionConstants.certificationCollection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise.reject(error)
                }

                var certifications: [String: Certification] = [:]
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

    func updateUser(_ user: User) -> Promise<Void> {
        return Promise { promise in
            let updatedUser = DomainToFirebaseMapper.mapUser(user: user)

            let userDocRef = Firestore.firestore().collection(CollectionConstants.userCollection).document(user.id!.value)
            userDocRef.updateData(updatedUser, completion: { (error) in
                if let error = error {
                    promise.reject(error)
                }

                CacheManager.userCache[user.id!] = user
                promise.fulfill_()
            })
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
