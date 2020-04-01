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
    
    private let cache = Cache<String, ExercisePost>()
    private let firebaseMappingCache = Cache<String, Any>() //Used to hold firebase document ids to internal domain object like Exercise
    
    func getPost(withId id: String) -> Promise<ExercisePost> {
            return Promise { promise in
                
                if let post = cache[id] {
                    return promise.fulfill(post)
                }
                
                let docRef = Firestore.firestore().collection(postsCollection).document(id)
                docRef.getDocument { doc, error in
                    guard error == nil, let doc = doc, doc.exists else {
                        return promise.reject(error!)
                    }

                    let userId = doc.data()?["created-by"] as! String
                    firstly {
                        Services.userService.getUser(withId: userId)
                    }.done { user in
                        var metricsPromises = [Promise<Int>]()
                        var exercisePromises = [Promise<[Exercise]>]()
                        var voteDirectionPromises = [Promise<VoteDirection>]()
                        var answerPromises = [Promise<[Answer]>]() //TODO: More efficient such that a count of answers is directly on the exercisePost structure. Same with other metrics.
                        
                        metricsPromises.append(self.getUpvoteCount(forPostWithId: doc.documentID, collection: self.postsCollection))
                        metricsPromises.append(self.getDownvoteCount(forPostWithId: doc.documentID, collection: self.postsCollection))
                        metricsPromises.append(self.getViewsCount(forPostWithId: doc.documentID))
                        exercisePromises.append(self.getExercises(forPostWithId: doc.documentID))
                        voteDirectionPromises.append(self.getVoteDirection(id: doc.documentID, collection: self.postsCollection))
                        answerPromises.append(self.getAnswers(forPostWithId: doc.documentID))
                        
                        firstly {
                            when(fulfilled: metricsPromises)
                        }.done { metricsResults in
                            firstly {
                                when(fulfilled: exercisePromises)
                            }.done { exercisesResults in
                                firstly {
                                    when(fulfilled: voteDirectionPromises)
                                }.done { voteDirectionResults in
                                    firstly {
                                        when(fulfilled: answerPromises)
                                    }.done { answerResults in
                                        let metrics = Metrics(views: metricsResults[2],
                                                             upvotes: metricsResults[0],
                                                             downvotes: metricsResults[1],
                                                             currentVoteDirection: voteDirectionResults[0])

                                        let postExercises = exercisesResults[0]
                                        var exercisePost = FirebaseToDomainMapper.mapExercisePost(fromData: doc.data()!,
                                                                               metrics: metrics,
                                                                               exercises: postExercises,
                                                                               answers: answerResults[0])
                                        exercisePost.createdBy = user
                                        //store in cache
                                        self.cache[exercisePost.id] = exercisePost
                                        
                                        return promise.fulfill(exercisePost)
                                    }
                                }
                            }
                        }
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
                var voteDirectionPromises = [Promise<VoteDirection>]()
                for document in answersSnapshot!.documents {
                    metricsPromises.append(self.getUpvoteCount(forPostWithId: document.documentID, collection: self.answerCollection))
                    metricsPromises.append(self.getDownvoteCount(forPostWithId: document.documentID, collection: self.answerCollection))
                    voteDirectionPromises.append(self.getVoteDirection(id: document.documentID, collection: self.answerCollection))
                }
                
                firstly {
                    Services.userService.getUser(withId: userId)
                }.done { userDetails in
                    firstly {
                        when(fulfilled: metricsPromises)
                    }.done { metricsResults in
                        firstly {
                            when(fulfilled: voteDirectionPromises)
                        }.done { voteDirections in
                            var answers = [Answer]()
                            var metricsIndex = 0
                            var voteDirectionIndex = 0
                            
                            for document in answersSnapshot!.documents {
                                answers.append(FirebaseToDomainMapper.mapAnswer(fromData: document.data(),
                                                              metrics: Metrics(upvotes: metricsResults[metricsIndex],
                                                                               downvotes: metricsResults[metricsIndex + 1],
                                                                               currentVoteDirection: voteDirections[voteDirectionIndex]),
                                                              createdBy: userDetails))
                                metricsIndex += 2
                                voteDirectionIndex += 1
                            }
                            return promise.fulfill(answers)
                        }
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
                            answers.append(FirebaseToDomainMapper.mapAnswer(fromData: document.data(),
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
        
    func getPosts(limit: Int = 10, lastPostSnapshot: DocumentSnapshot?) -> Promise<PaginatedGetPostsResult> {
        return Promise { promise in

            let db = Firestore.firestore()
            var query = db.collection(K.Firestore.posts).order(by: "modified-date", descending: true).limit(to: limit)
            
            if let lastPostSnapshot = lastPostSnapshot {
                query = query.start(afterDocument: lastPostSnapshot)
            }
            
            query.getDocuments() { querySnapshot, error in
                if let error = error {
                    return promise.reject(error)
                }
                
                if querySnapshot!.documents.count == 0 { //no results, return early
                    let res = PaginatedGetPostsResult(posts: [], lastSnapshot: nil)
                    return promise.fulfill(res)
                }
                
                //read through items in order, and setup PromisesExecution Array in SERIES/sequence
                //https://github.com/mxcl/PromiseKit/blob/master/Documentation/CommonPatterns.md --Chaining Sequences
                
                //Example on how to sequentially chain promises.
                //Going from [Promise<Post>] (array of promises)  => [()->Promise<Post>] (Aka Array of Closures that return Promises)
                //ie. from [ExercisepostPromise] to [ClosureToExercisepostPromiseType]
                
                let closurePromisesArr: [ClosureToExercisepostPromiseType] = querySnapshot!.documents.map { doc in
                    return {
                        
                        return Promise<ExercisePost> { pr in
                            //actually call individual getPost(id)
                            firstly {
                                self.getPost(withId:doc.documentID)
                            }.done { post in
                                pr.fulfill(post)
                            }.catch { err in
                                pr.reject(err)
                            }
                        }
                    }
                }
                
                Promise.chain(closurePromisesArr).done { posts in
                    let result = PaginatedGetPostsResult(posts:posts, lastSnapshot: querySnapshot!.documents.last)
                    return promise.fulfill(result)
                }.catch { err2 in
                    return promise.reject(err2)
                }
            }
        }
    }
    
    func getPosts(forUser user: User) -> Promise<[ExercisePost]> {
        return Promise {promise in
            let exercisePostRef = Firestore.firestore().collection(postsCollection).whereField("created-by", isEqualTo: user.id!)
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
                    metricsPromises.append(self.getViewsCount(forPostWithId: document.documentID))
                    exercisePromises.append(self.getExercises(forPostWithId: document.documentID))
                    voteDirectionPromises.append(self.getVoteDirection(id: document.documentID, collection: self.postsCollection))
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
                                    let metrics = Metrics(views: metricsResults[metricsIndex + 2],
                                                         upvotes: metricsResults[metricsIndex],
                                                         downvotes: metricsResults[metricsIndex + 1],
                                                         currentVoteDirection: voteDirectionResults[voteDirectionIndex])
                                    
                                    let postExercises = exercisesResults[exercisesIndex]
                                    var exercisePost = FirebaseToDomainMapper.mapExercisePost(fromData: document.data(),
                                                                           metrics: metrics,
                                                                           exercises: postExercises,
                                                                           answers: answerResults[answerIndex])
                                    exercisePost.createdBy = user
                                    userPosts.append(exercisePost)
                                    metricsIndex += 3
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
            if let exercises = firebaseMappingCache["exercises"] as? [String:Exercise] {
                return promise.fulfill(exercises)
            }
            
            let exercisesRef = Firestore.firestore().collection(exerciseCollection)
            exercisesRef.getDocuments { (exercisesSnapshot, error) in
                if let error = error {
                    try? Services.analyticsService.logEvent(event: AnalyticsEvent(name: "get", parameters: [
                        "service": "ExercisePostService",
                        "method": "getExercises",
                        "error": error.localizedDescription]))
                    return promise.reject(error)
                }
                
                var exercises: [String:Exercise] = [:]
                for document in exercisesSnapshot!.documents {
                    exercises[document.documentID] = Exercise(id: document.documentID,
                                                              name: document.data()["name"] as! String
                                                            )
                }
                self.firebaseMappingCache.insert(exercises, forKey: "exercises")
                return promise.fulfill(exercises)
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
                let updatedStatus = direction.get()
                
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
    
    func getVoteDirection(id: String, collection: String) -> Promise<VoteDirection> {
        return Promise { promise in
            firstly {
                Services.userService.getCurrentUser()
            }.done { currentUser in
                let voteRef = Firestore.firestore().collection("\(collection)/\(id)/\(self.votesCollection)").whereField("voted-by", isEqualTo: currentUser.id!)
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
            var newAnswer = answer
            newAnswer.id = newAnswerRef.documentID
            newAnswerRef.setData(DomainToFirebaseMapper.mapAnswer(from: newAnswer), completion: { error in
                if let error = error {
                    return promise.reject(error)
                }
                return promise.fulfill_()
            })
            
        }
    }
       
    func createPost(post: ExercisePost) -> Promise<ExercisePost> {
        return Promise { promise in
            let newDocRef = Firestore.firestore().collection(postsCollection).document()
            var newPost = post
            newPost.id = newDocRef.documentID
            
            newDocRef.setData(DomainToFirebaseMapper.mapExercisePost(post: newPost)) { error in
                if let error = error {
                    return promise.reject(error)
                }
            }
            
            if post.exercises.count > 0 {
                newDocRef.collection("exercises").addDocument(data: ["exercise": Firestore.firestore().document("/\(exerciseCollection)/\(post.exercises[0].id)")]) { error in
                    if let error = error {
                        return promise.reject(error)
                    }
                    return promise.fulfill(newPost)
                }
            }
            return promise.fulfill(newPost)
        }
    }
    
    //Will merge attributes of the dictionary arg with the existing Firebase document. That way we're only updating the delta
    //merge:true allows this merge with previous data
    //merge:false does a full overwrite of a document
    func updatePost(post: ExercisePost) -> Promise<Void> {
        return Promise { promise in
            
            let id = post.id
            let newPost = post
            //invalidate cache item
            if let tmp = cache[id] {
                cache[id] = nil
            }
            
            let db = Firestore.firestore()
            let docRef = db.collection(K.Firestore.posts).document(id)
            
            docRef.setData(DomainToFirebaseMapper.mapExercisePost(post: newPost), merge:true) { err in
                if let err = err {
                    return promise.reject(err)
                } else {
                    promise.fulfill_()
                }
            }            
        }
    }
    
    //Deletes ExercisePost document, after first deleting it's images (if any), and corresponding answers
    func deletePost(_ post: ExercisePost) -> Promise<Void> {
        return Promise { promise in
            
            let id = post.id
            
            //invalidate cache item
            if let tmp = cache[id] {
                cache[id] = nil
            }
            
            let docRef = Firestore.firestore().collection(postsCollection).document(id)
            
            //setup execution the firestore delete answers request, and storage-delete-request in parallel
            var voidPromises = [Promise<Void>]()
            voidPromises.append(self.deleteAnswers(forPostWithId: id))
            
            if let imagefilename = post.imagePath {
                voidPromises.append(Services.storageService.deleteImage(filename: imagefilename))
            }
            
            firstly {
                when(fulfilled: voidPromises)
            }.done { _ in
                docRef.delete() { error in
                    if let error = error {
                        promise.reject(error)
                    } else {
                        promise.fulfill_()
                    }
                }
            }.catch { err in
                promise.reject(err)
            }
        }
    }
    
    //Recursively deletes all the answer(documents) for a given PostID
    func deleteAnswers(forPostWithId postId: String) -> Promise<Void> {
    
        return Promise { promise in
            let answersRef = Firestore.firestore().collection(answerCollection).whereField("exercise-post", isEqualTo: postId)
            answersRef.getDocuments { (answersSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var answersDeletePromises = [Promise<Void>]()
                for document in answersSnapshot!.documents {
                    answersDeletePromises.append(self.deleteAnswer(withId: document.documentID))
                }
                
                firstly {
                    when(fulfilled: answersDeletePromises)
                }.done { _ in
                    return promise.fulfill_()
                }.catch { err in
                    print("deleteAnswers: Failed to delete all answers for given Post:\(postId)")
                    return promise.reject(err)
                }
            }
        }
    }
    
    //TODO: Create delete policy: because deleting answer only deletes document at Answers (not a recurse delete on collection its subcollections. NOT the subcollection documents like VOTES-
    //so it'll look like an nil intermediate node
    func deleteAnswer(withId id: String) -> Promise<Void> {
        return Promise { promise in
            let answerRef = Firestore.firestore().collection(answerCollection).document(id)
            
            answerRef.delete() { err in
                if let error = err {
                    print("deleteAnswer: failure delete answer(\(id))")
                    return promise.reject(error)
                } else {
                    print("deleteAnswer: success delete answer(\(id))")
                    return promise.fulfill_()
                }
                
            }
        }
    }
}
