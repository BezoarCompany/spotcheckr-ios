import PromiseKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ExercisePostService: ExercisePostProtocol {
    private let postsCollection = "posts"
    private let votesCollection = "votes"
    private let likeCollection = "likes"
    private let exerciseCollection = "exercises"
    private let viewsCollection = "views"
    private let answerCollection = "answers"
    private let exerciseTypeCollection = "exercise-types"
    
    func getPost(withId id: String) -> Promise<ExercisePost> {
            return Promise { promise in
                let docRef = Firestore.firestore().collection(postsCollection).document(id)
                docRef.getDocument { doc, error in
                    guard error == nil, let doc = doc, doc.exists else {
                        return promise.reject(error!)
                    }

                    let userId = doc.data()?["created-by"] as! String
                    firstly {
                        Services.userService.getUser(withId: userId)
                    }.done { user in
                        let date = doc.data()?["created-date"] as? Timestamp
                        
                        let exercisePost = ExercisePost(id: doc.data()?["id"] as! String,
                                                        title: doc.data()?["title"] as! String,
                                                        description: doc.data()?["description"] as! String,
                                                        createdBy: user,
                                                        dateCreated: date?.dateValue(),
                                                        imagePath: doc.data()?["image-path"] as? String
                                                        
                                            )                        
                        
                        return promise.fulfill(exercisePost)
                    }.catch { error in
                        return promise.reject(error)
                    }
            }
        }
    }
    
    func getAnswers(byUserWithId userId: String) -> Promise<[Answer]> {
        return Promise { promise in
            let answersRef = Firestore.firestore().collection(answerCollection).whereField("created-by", isEqualTo: userId)
            answersRef.getDocuments { (answersSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                
                var metricsPromises = [Promise<Int>]()
                for document in answersSnapshot!.documents {
                    metricsPromises.append(self.getUpvoteCount(forPostWithId: document.documentID, collection: self.answerCollection))
                    metricsPromises.append(self.getDownvoteCount(forPostWithId: document.documentID, collection: self.answerCollection))
                }
                
                firstly {
                    Services.userService.getUser(withId: userId)
                }.done { userDetails in
                    firstly {
                        when(fulfilled: metricsPromises)
                    }.done { metricsResults in
                        var answers = [Answer]()
                        var metricsIndex = 0
                        
                        for document in answersSnapshot!.documents {
                            answers.append(self.mapAnswer(fromData: document.data(),
                                                          metrics: Metrics(upvotes: metricsResults[metricsIndex],
                                                                           downvotes: metricsResults[metricsIndex + 1]),
                                                          createdBy: userDetails))
                            metricsIndex += 2
                        }
                        return promise.fulfill(answers)
                    }
                }
            }
        }
    }
    
    func getAnswers(forPostWithId postId: String) -> Promise<[Answer]> {
        return Promise { promise in
            let answersRef = Firestore.firestore().collection(answerCollection).whereField("exercise-post", isEqualTo: postId)
            answersRef.getDocuments { (answersSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                let answersCreatedBy = answersSnapshot!.documents.map{ Services.userService.getUser(withId: $0.data()["created-by"] as! String)}
                var metricsPromises = [Promise<Int>]()
                for document in answersSnapshot!.documents {
                    metricsPromises.append(self.getUpvoteCount(forPostWithId: document.documentID, collection: self.answerCollection))
                    metricsPromises.append(self.getDownvoteCount(forPostWithId: document.documentID, collection: self.answerCollection))
                }
                
                firstly {
                    when(fulfilled: answersCreatedBy)
                }.done { createdByResults in
                    firstly {
                        when(fulfilled: metricsPromises)
                    }.done { metricsResults in
                        var answers = [Answer]()
                        var usersIndex = 0
                        var metricsIndex = 0
                        for document in answersSnapshot!.documents {
                            answers.append(self.mapAnswer(fromData: document.data(),
                                                          metrics: Metrics(upvotes: metricsResults[metricsIndex],
                                                                           downvotes: metricsResults[metricsIndex + 1]),
                                                          createdBy: createdByResults[usersIndex]))
                            usersIndex += 1
                            metricsIndex += 2
                        }
                        
                        return promise.fulfill(answers)
                    }
                }
            }
        }
    }
    
    //TODO: add more parameters. page#, context parameters?
    func getPosts(success: @escaping ([ExercisePost])->Void) -> Promise<[ExercisePost]> {
        return Promise { promise in

            let db = Firestore.firestore()
            let docRef = db.collection(K.Firestore.posts).order(by: "modified-date")
            
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
    
    func getPosts(forUserWithId userId: String) -> Promise<[ExercisePost]> {
        return Promise {promise in
            let exercisePostRef = Firestore.firestore().collection(postsCollection).whereField("created-by", isEqualTo: userId)
            exercisePostRef.getDocuments { (postsSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var metricsPromises = [Promise<Int>]()
                var exercisePromises = [Promise<[Exercise]>]()
                var voteDirectionPromises = [Promise<VoteDirection>]()
                var answerPromises = [Promise<[Answer]>]() //TODO: More efficient such that a count of answers is directly on the exercisePost structure. Same with other metrics.
                
                for document in postsSnapshot!.documents {
                    metricsPromises.append(self.getUpvoteCount(forPostWithId: document.documentID, collection: self.postsCollection))
                    metricsPromises.append(self.getDownvoteCount(forPostWithId: document.documentID, collection: self.postsCollection))
                    metricsPromises.append(self.getLikesCount(forPostWithId: document.documentID))
                    metricsPromises.append(self.getViewsCount(forPostWithId: document.documentID))
                    exercisePromises.append(self.getExercises(forPostWithId: document.documentID))
                    voteDirectionPromises.append(self.getVoteDirection(forPostWithId: document.documentID))
                    answerPromises.append(self.getAnswers(forPostWithId: document.documentID))
                }
                
                //TODO: Figure out how to execute different types of array of promises at the same time intead of chaining like this :/
                firstly {
                    when(fulfilled: metricsPromises)
                }.done { metricsResults in
                    firstly {
                        when(fulfilled: exercisePromises)
                    }.done { exercisesResults in
                        firstly {
                            when(fulfilled: voteDirectionPromises)
                        }.done{ voteDirectionResults in
                            firstly {
                                when(fulfilled: answerPromises)
                            }.done { answerResults in
                                var userPosts = [ExercisePost]()
                                var metricsIndex = 0
                                var exercisesIndex = 0
                                var voteDirectionIndex = 0
                                var answerIndex = 0
                                for document in postsSnapshot!.documents {
                                    let metrics = Metrics(views: metricsResults[metricsIndex + 3],
                                                         likes: metricsResults[metricsIndex + 2],
                                                         upvotes: metricsResults[metricsIndex],
                                                         downvotes: metricsResults[metricsIndex + 1],
                                                         currentVoteDirection: voteDirectionResults[voteDirectionIndex])
                                    
                                    let postExercises = exercisesResults[exercisesIndex]
                                    
                                    userPosts.append(self.mapExercisePost(fromData: document.data(),
                                                                         metrics: metrics,
                                                                         exercises: postExercises,
                                                                         answers: answerResults[answerIndex]))
                                    metricsIndex += 4
                                    exercisesIndex += 1
                                    voteDirectionIndex += 1
                                    answerIndex += 1
                                }

                                return promise.fulfill(userPosts)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUpvoteCount(forPostWithId postId: String, collection: String) -> Promise<Int> {
        return Promise { promise in
            //TODO: Pull from cache for a post/answer
            let upvotesRef = Firestore.firestore().collection("\(collection)/\(postId)/\(self.votesCollection)").whereField("status", isEqualTo: 1)
            upvotesRef.getDocuments { (upvoteSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                //TODO: Store in cache. When a post/answer is upvoted we will pull the item from the cache, increment it, and store it back.
                return promise.fulfill(upvoteSnapshot!.documents.count)
            }
        }
    }
    
    func getDownvoteCount(forPostWithId postId: String, collection: String) -> Promise<Int> {
        return Promise { promise in
            //TODO: Pull from cache for a post/answer
            let downvotesRef = Firestore.firestore().collection("\(self.postsCollection)/\(postId)/\(self.votesCollection)").whereField("status", isEqualTo: -1)
            downvotesRef.getDocuments { (downvoteSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                //TODO: Store in cache. When a post/answer is downvoted we will pull the item from the cache, increment it, and store it back.
                return promise.fulfill(downvoteSnapshot!.documents.count)
            }
        }
    }
    
    func getLikesCount(forPostWithId postId: String) -> Promise<Int> {
        return Promise { promise in
            //TODO: Pull from cache for a post
            let likesRef = Firestore.firestore().collection("\(self.postsCollection)/\(postId)/\(self.likeCollection)")
            likesRef.getDocuments { (likesSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                //TODO: Store in cache if necessary. When someone likes the post we will add their entry to post likes subcollection, pull the current value from the cache, increment the likes in the cache and then store it back there too.
                return promise.fulfill(likesSnapshot!.documents.count)
            }
        }
    }
    
    func getViewsCount(forPostWithId postId: String) -> Promise<Int> {
        return Promise { promise in
            //TODO: Pull from cache for a post
            let viewsRef = Firestore.firestore().collection("\(self.postsCollection)/\(postId)/\(self.viewsCollection)")
            viewsRef.getDocuments { (viewsSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                //TODO: Store in cache if necessary. When someone hits the detail view for a post we will add their entry to post views subcollection, pull the current value from the cache, increment the views in the cache and then store it back there too.
                return promise.fulfill(viewsSnapshot!.documents.count)
            }
        }
    }
    
    func getExercises(forPostWithId postId: String) -> Promise<[Exercise]> {
        return Promise { promise in
            //TODO: Pull from cache
            let exercisesRef = Firestore.firestore().collection("\(self.postsCollection)/\(postId)/\(self.exerciseCollection)")
            exercisesRef.getDocuments { (exercisesSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                firstly {
                    self.getExercises()
                }.done { exercises in
                    var postExercises = [Exercise]()
                    for document in exercisesSnapshot!.documents {
                        let exercise = exercises[(document.data()["exercise"] as! DocumentReference).documentID]!
                        postExercises.append(exercise)
                    }
                    //TODO: Store in cache, if they edit a post and add an exercise then we will edit the cached entry and store it again so we don't have to pull all exercises often.
                    return promise.fulfill(postExercises)
                }
                
            }
        }
    }
    
    func getExercises() -> Promise<[String:Exercise]> {
        return Promise { promise in
            //TODO: Pull from cache
            let exercisesRef = Firestore.firestore().collection(exerciseCollection)
            exercisesRef.getDocuments { (exercisesSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var exercises: [String:Exercise] = [:]
                
                firstly {
                    self.getExerciseTypes()
                }.done { exerciseTypes in
                    for document in exercisesSnapshot!.documents {
                        exercises[document.documentID] = Exercise(name: document.data()["name"] as! String,
                                                                  type: exerciseTypes[(document.data()["type"] as! DocumentReference).documentID])
                    }
                    
                    //TODO: Store in cache
                    return promise.fulfill(exercises)
                }
            }
        }
    }
    
    func getExerciseTypes() -> Promise<[String:ExerciseType]> {
        return Promise { promise in
            //TODO: Check if in cache and pull from there.
            let exerciseTypesRef = Firestore.firestore().collection(exerciseTypeCollection)
            exerciseTypesRef.getDocuments { (typesSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var  exerciseTypes: [String:ExerciseType] = [:]
                
                for document in typesSnapshot!.documents {
                    var exerciseType: ExerciseType
                    switch document.data()["name"] as! String {
                    case "Strength":
                        exerciseType =  .Strength
                        break
                    case "Endurance":
                        exerciseType = .Endurance
                        break
                    case "Flexibility":
                        exerciseType = .Flexibility
                        break
                    case "Balance":
                        exerciseType = .Balance
                        break
                    default:
                        return promise.reject(NSError()) //Unrecognized exercise type
                    }
                    
                    exerciseTypes[document.documentID] = exerciseType
                }
                
                //TODO: Store in cache
                return promise.fulfill(exerciseTypes)
            }
        }
    }
    
    func votePost(postId: String, userId: String, direction: VoteDirection) -> Promise<Void> {
        return adjustVote(rootCollection: self.postsCollection, postOrAnswerId: postId, userId: userId, direction: direction)
    }
    
    func voteAnswer(answerId: String, userId: String, direction: VoteDirection) -> Promise<Void> {
        return adjustVote(rootCollection: self.answerCollection, postOrAnswerId: answerId, userId: userId, direction: direction)
    }
    
    private func adjustVote(rootCollection: String, postOrAnswerId: String, userId: String, direction: VoteDirection) -> Promise<Void> {
        let collectionPath = "\(rootCollection)/\(postOrAnswerId)/\(votesCollection)"
        return Promise { promise in
            let voteRef = Firestore.firestore().collection(collectionPath).whereField("voted-by", isEqualTo: userId)
            voteRef.getDocuments { (voteSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                var updatedStatus = direction.get()
                
                //Vote does not exist so add the vote
                if voteSnapshot?.count == 0 {
                    Firestore.firestore().collection(collectionPath).addDocument(data: [
                        "status": updatedStatus,
                        "voted-by": userId
                    ]){ error in
                        if error != nil {
                          return promise.reject(error!)
                        }
                        promise.fulfill_()
                    }
                }
                else {
                    //Vote already exists so update the value
                    let doc = voteSnapshot?.documents[0]
                    let currentStatus = doc?.data()["status"] as! Int
                    
                    if currentStatus == VoteDirection.Up.get() || currentStatus == VoteDirection.Down.get() {
                        updatedStatus = VoteDirection.Neutral.get()
                    }
                    
                    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                        transaction.updateData(["status" : updatedStatus], forDocument: doc!.reference)
                    }) { (obj, error) in
                        if let error = error {
                            return promise.reject(error)
                        }
                        promise.fulfill_()
                    }
                }
                
            }
        }
        
    }
    
    func getVoteDirection(forPostWithId postId: String) -> Promise<VoteDirection> {
        return Promise { promise in
            firstly {
                Services.userService.getCurrentUser()
            }.done { currentUser in
                let voteRef = Firestore.firestore().collection("\(self.postsCollection)/\(postId)/\(self.votesCollection)").whereField("voted-by", isEqualTo: currentUser.id)
                voteRef.getDocuments { (voteSnapshot, error) in
                    if let error = error {
                        return promise.reject(error)
                    }
                    
                    var voteDirection: VoteDirection = .Neutral
                    if voteSnapshot!.count > 0 {
                        voteDirection = VoteDirection(rawValue: voteSnapshot!.documents[0].data()["status"] as! Int)!
                    }
                    
                    return promise.fulfill(voteDirection)
                }
            }.catch { error in
                return promise.reject(error)
            }
        }
    }
    
    func writeAnswer(answer: Answer) -> Promise<Void> {
        return Promise { promise in
            let newAnswerRef = Firestore.firestore().collection(self.answerCollection).document()
            newAnswerRef.setData(self.mapAnswer(from: answer), completion: { error in
                if let error = error {
                    return promise.reject(error)
                }
                return promise.fulfill_()
            })
        }
    }
    
    private func mapAnswer(from: Answer) -> [String:Any] {
        var firebaseAnswer = [String:Any]()
        firebaseAnswer["created-by"] = from.createdBy?.id
        firebaseAnswer["created-date"] = from.dateCreated
        firebaseAnswer["modified-date"] = from.dateModified
        firebaseAnswer["text"] = from.text
        firebaseAnswer["exercise-post"] = from.exercisePost?.id
        return firebaseAnswer
    }
    
    private func mapAnswer(fromData data:[String:Any],
                           metrics: Metrics,
                           createdBy: User) -> Answer {
        var answer = Answer()
        answer.text = data.keys.contains("text") ? data["text"] as! String : ""
        answer.upvotes = metrics.upvotes
        answer.downvotes = metrics.downvotes
        answer.dateCreated = data.keys.contains("created-date") ? (data["created-date"] as! Timestamp).dateValue() : nil
        answer.dateModified = data.keys.contains("modified-date") ? (data["modified-date"] as! Timestamp).dateValue() : nil
        answer.createdBy = createdBy
        return answer
    }
    
    //TODO: Figure out a better way to map from Firebase -> Model.
    private func mapExercisePost(fromData data:[String: Any],
                                 metrics: Metrics,
                                 exercises: [Exercise],
                                 answers: [Answer] = [Answer]()) -> ExercisePost {
        var post = ExercisePost()
        post.id = data.keys.contains("id") ? data["id"] as! String : ""
        post.title = data.keys.contains("title") ? data["title"] as! String : ""
        post.description = data.keys.contains("description") ? data["description"] as! String : ""
        post.dateCreated = data.keys.contains("created-date") ? (data["created-date"] as! Timestamp).dateValue() : nil
        post.dateModified = data.keys.contains("modified-date") ? (data["modified-date"] as! Timestamp).dateValue() : nil
        post.metrics = metrics
        post.exercises = exercises
        post.answers = answers
        return post
    }
        
    func writePost(dict: [String: Any]) -> Promise<Void> {
        return Promise { promise in
            
            let db = Firestore.firestore()
            let newDocRef = db.collection(K.Firestore.posts).document()
            
            var newDict = dict
            newDict.add(["id" : newDocRef.documentID])
            
            newDocRef.setData(newDict) { err in
                if let err = err {
                    return promise.reject(err)
                } else {
                    promise.fulfill_()
                }
            }
        }
    }
}
