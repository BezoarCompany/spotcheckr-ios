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
}
