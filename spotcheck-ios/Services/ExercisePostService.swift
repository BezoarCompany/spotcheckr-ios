import PromiseKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ExercisePostService: ExercisePostProtocol {
    private let postsCollection = "posts"
    private let userService = UserService()
    
    func getPost(withId id: String) -> Promise<ExercisePost> {
            return Promise { promise in
                let docRef = Firestore.firestore().collection(postsCollection).document(id)
                docRef.getDocument { doc, error in
                    guard error == nil, let doc = doc, doc.exists else {
                        return promise.reject(error!)
                    }

                    let userId = doc.data()?["created-by"] as! String
                    firstly {
                        self.userService.getUser(withId: userId)
                    }.done { user in
                        let exercisePost = ExercisePost(id: doc.data()?["id"] as! String,
                                                        title: doc.data()?["title"] as! String,
                                                        description: doc.data()?["description"] as! String,
                                                        createdBy: user)
                        return promise.fulfill(exercisePost)
                    }.catch { error in
                        return promise.reject(error)
                    }
            }
        }
    }
    
    func getAnswers(forUserWithId userId: String) -> Promise<[Answer]> {
        return Promise { promise in
            //TODO: Implement
            return promise.fulfill([Answer]())
        }
    }
    
    //TODO: add more parameters. page#, context parameters?
    func getPosts(success: @escaping ([ExercisePost])->Void) -> Promise<[ExercisePost]> {
        return Promise { promise in

            let db = Firestore.firestore()
            let docRef = db.collection(K.Firestore.posts)
            
            var resultPosts = [ExercisePost]()
            
            docRef.getDocuments() { querySnapshot, error in
                guard error == nil, let querySnapshot = querySnapshot, !querySnapshot.isEmpty else {
                    return promise.reject(error!)
                }
                
                for doc in querySnapshot.documents {
                    print("\(doc.documentID) => \(doc.data())")
                    
                    firstly {
                        self.getPost(withId:doc.documentID)
                    }.done { post in
                        print("@getPosts-ServiceCall------resultPosts:")
                        
                        resultPosts.append(post)
                        success(resultPosts)
                        print(resultPosts)
                    }.catch { err in
                        print("[ERROR]: looping through getPosts document ")
                        return promise.reject(err)                        
                    }
                }                
                return promise.fulfill(resultPosts)
            }
        }
    }
}
