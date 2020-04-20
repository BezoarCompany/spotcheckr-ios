import PromiseKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ExercisePostService: ExercisePostProtocol {
    private let cache = Cache<ExercisePostID, ExercisePost>()
    private let firebaseMappingCache = Cache<String, Any>() //Used to hold firebase document ids to internal domain object like Exercise
    
    func getPost(withId id: ExercisePostID) -> Promise<ExercisePost> {
            return Promise { promise in
                
                if let post = cache[id] {
                    return promise.fulfill(post)
                }
                print("postCollection: \(CollectionConstants.postsCollection) [\(id)]")
                let docRef = Firestore.firestore().collection(CollectionConstants.postsCollection).document(id.value)
                docRef.getDocument { doc, error in
                    guard error == nil, let doc = doc, doc.exists else {
                        return promise.reject(error!)
                    }

                    let userId = UserID(doc.data()?["created-by"] as! String)
                    firstly {
                        Services.userService.getUser(withId: userId)
                    }.done { user in
                        var exercisePromises = [Promise<[Exercise]>]()
                        var voteDirectionPromises = [Promise<VoteDirection>]()
                        
                        exercisePromises.append(self.getExercises(forPostWithId: ExercisePostID(doc.documentID)))
                        voteDirectionPromises.append(self.getVoteDirection(contentId: ExercisePostID(doc.documentID), collection: CollectionConstants.postsCollection))
                        
                        firstly {
                            when(fulfilled: exercisePromises)
                        }.done { exercisesResults in
                            firstly {
                                when(fulfilled: voteDirectionPromises)
                            }.done { voteDirectionResults in
                                let metrics = Metrics(upvotes: doc.data()?["upvote-count"] != nil ? doc.data()?["upvote-count"] as! Int : 0,
                                                      downvotes: doc.data()?["downvote-count"] != nil ? doc.data()?["downvote-count"] as! Int : 0,
                                                     currentVoteDirection: voteDirectionResults[0])

                                let postExercises = exercisesResults[0]
                                let exercisePost = FirebaseToDomainMapper.mapExercisePost(fromData: doc.data()!,
                                                                       metrics: metrics,
                                                                       exercises: postExercises)
                                exercisePost.createdBy = user
                                //store in cache
                                self.cache[exercisePost.id!] = exercisePost
                                
                                return promise.fulfill(exercisePost)
                            }
                        }
                    }.catch { error in
                        return promise.reject(error)
                    }
            }
        }
    }
    
    func getAnswers(byUserWithId userId: UserID) -> Promise<[Answer]> {
        return Promise { promise in
            let answersRef = Firestore.firestore().collection(CollectionConstants.answerCollection).whereField("created-by", isEqualTo: userId.value)
            answersRef.getDocuments { (answersSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var voteDirectionPromises = [Promise<VoteDirection>]()
                for document in answersSnapshot!.documents {
                    voteDirectionPromises.append(self.getVoteDirection(contentId: AnswerID(document.documentID), collection: CollectionConstants.answerCollection))
                }
                
                firstly {
                    Services.userService.getUser(withId: userId)
                }.done { userDetails in
                   firstly {
                        when(fulfilled: voteDirectionPromises)
                    }.done { voteDirections in
                        var answers = [Answer]()
                        var voteDirectionIndex = 0
                        
                        for document in answersSnapshot!.documents {
                            answers.append(FirebaseToDomainMapper.mapAnswer(fromData: document.data(),
                                                                            metrics: Metrics(upvotes: document.data()["upvote-count"] != nil ? document.data()["upvote-count"] as! Int : 0,
                                                                                             downvotes: document.data()["downvote-count"] != nil ? document.data()["downvote-count"] as! Int : 0,
                                                                           currentVoteDirection: voteDirections[voteDirectionIndex]),
                                                          createdBy: userDetails))
                            voteDirectionIndex += 1
                        }
                        return promise.fulfill(answers)
                    }
                }
            }
        }
    }
    
    func getAnswers(forPostWithId postId: ExercisePostID) -> Promise<[Answer]> {
        return Promise { promise in
            let answersRef = Firestore.firestore().collection(CollectionConstants.answerCollection).whereField("exercise-post", isEqualTo: postId.value)
            answersRef.getDocuments { (answersSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                let answersCreatedBy = answersSnapshot!.documents.map{ Services.userService.getUser(withId: UserID($0.data()["created-by"] as! String))}
                
                firstly {
                    when(fulfilled: answersCreatedBy)
                }.done { createdByResults in
                    var answers = [Answer]()
                    var usersIndex = 0
                    
                    for document in answersSnapshot!.documents {
                        answers.append(FirebaseToDomainMapper.mapAnswer(fromData: document.data(),
                                                                        metrics: Metrics(upvotes: document.data()["upvote-count"] != nil ? document.data()["upvote-count"] as! Int : 0,
                                                                                         downvotes: document.data()["downvote-count"] != nil ? document.data()["downvote-count"] as! Int : 0),
                                                      createdBy: createdByResults[usersIndex]))
                        usersIndex += 1
                    }
                    
                    return promise.fulfill(answers)
                }
            }
        }
    }
        
    func getPosts(limit: Int = 10, lastPostSnapshot: DocumentSnapshot?) -> Promise<PaginatedGetPostsResult> {
        return Promise { promise in

            let db = Firestore.firestore()
            var query = db.collection(CollectionConstants.postsCollection).order(by: "modified-date", descending: true).limit(to: limit)
            
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
                                self.getPost(withId: ExercisePostID(doc.documentID))
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
            let exercisePostRef = Firestore.firestore().collection(CollectionConstants.postsCollection).whereField("created-by", isEqualTo: user.id!.value)
            exercisePostRef.getDocuments { (postsSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var exercisePromises = [Promise<[Exercise]>]()
                var voteDirectionPromises = [Promise<VoteDirection>]()
                
                for document in postsSnapshot!.documents {
                    exercisePromises.append(self.getExercises(forPostWithId: ExercisePostID(document.documentID)))
                    voteDirectionPromises.append(self.getVoteDirection(contentId: ExercisePostID(document.documentID), collection: CollectionConstants.postsCollection))
                }
                
                //TODO: Figure out how to execute different types of array of promises at the same time intead of chaining like this :/
                firstly {
                    when(fulfilled: exercisePromises)
                }.done { exercisesResults in
                    firstly {
                        when(fulfilled: voteDirectionPromises)
                    }.done{ voteDirectionResults in
                        var userPosts = [ExercisePost]()
                        var exercisesIndex = 0
                        var voteDirectionIndex = 0
                        for document in postsSnapshot!.documents {
                            let metrics = Metrics(upvotes: document.data()["upvote-count"] != nil ? document.data()["upvote-count"] as! Int : 0,
                                                  downvotes: document.data()["downvote-count"] != nil ? document.data()["downvote-count"] as! Int : 0,
                                                 currentVoteDirection: voteDirectionResults[voteDirectionIndex])
                            
                            let postExercises = exercisesResults[exercisesIndex]
                            let exercisePost = FirebaseToDomainMapper.mapExercisePost(fromData: document.data(),
                                                                   metrics: metrics,
                                                                   exercises: postExercises)
                            exercisePost.createdBy = user
                            userPosts.append(exercisePost)
                            exercisesIndex += 1
                            voteDirectionIndex += 1
                        }

                        return promise.fulfill(userPosts)
                    }
            }
            }
        }
    }
    
    func getExercises(forPostWithId postId: ExercisePostID) -> Promise<[Exercise]> {
        return Promise { promise in
            //TODO: Pull from cache
            let exercisesRef = Firestore.firestore().collection("\(CollectionConstants.postsCollection)/\(postId)/\(CollectionConstants.exerciseCollection)")
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
            
            let exercisesRef = Firestore.firestore().collection(CollectionConstants.exerciseCollection)
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
    
    func voteContent(contentId: GenericID, userId: UserID, direction: VoteDirection) -> Promise<Void> {
        var contentCollection: String
        if contentId is AnswerID {
            contentCollection = CollectionConstants.answerCollection
        }
        else {
            contentCollection = CollectionConstants.postsCollection
        }
        
        let parentDocPath = "/\(contentCollection)/\(contentId.value)"
        let parentDocRef = Firestore.firestore().document(parentDocPath)
        let collectionPath = "\(parentDocPath)/\(CollectionConstants.votesCollection)"
        return Promise { promise in
            let voteRef = Firestore.firestore().collection(collectionPath).whereField("voted-by", isEqualTo: userId.value)
            
            voteRef.getDocuments { (voteSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                Firestore.firestore().runTransaction({(transaction, errorPointer) -> Any? in
                    do {
                        let updatedStatus = direction.get()
                        var voteCountField: String? = nil
                        
                        let parentDoc = try transaction.getDocument(parentDocRef).data()
                        guard let parentDocData = parentDoc else { return nil }
                        
                        //Vote does not exist so add the vote
                        if voteSnapshot?.count == 0 {
                            let newVoteRef = Firestore.firestore().collection(collectionPath).document()
                            transaction.setData([
                                "status": updatedStatus,
                                "voted-by": userId
                            ], forDocument: newVoteRef)
                            switch direction {
                            case .Up:
                                voteCountField = "upvote-count"
                            case .Down:
                                voteCountField = "downvote-count"
                            default:
                                break
                            }
                            if let voteCountField = voteCountField {
                                let oldVoteCount = parentDocData[voteCountField] != nil ? parentDocData[voteCountField] as! Int : 0
                                let newVoteCount = oldVoteCount + 1
                                transaction.updateData([voteCountField: newVoteCount], forDocument: parentDocRef)
                            }
                        }
                        else {
                            //Vote already exists so update the value
                            let doc = voteSnapshot?.documents[0]
                            var upvoteCount = parentDocData["upvote-count"] != nil ? parentDocData["upvote-count"] as! Int : 0
                            var downvoteCount = parentDocData["downvote-count"] != nil ? parentDocData["downvote-count"] as! Int : 0
                            let oldStatus = VoteDirection(rawValue: doc!.data()["status"] as! Int)
                            if oldStatus == .Up && direction == .Down {
                                upvoteCount -= 1
                                downvoteCount += 1
                            }
                            else if oldStatus == .Up && direction == .Neutral {
                                upvoteCount -= 1
                            }
                            else if oldStatus == .Down && direction == .Up {
                                upvoteCount += 1
                                downvoteCount -= 1
                            }
                            else if oldStatus == .Down && direction == .Neutral {
                                downvoteCount -= 1
                            }
                            else if oldStatus == .Neutral && direction == .Up {
                                upvoteCount += 1
                            }
                            else if oldStatus == .Neutral && direction == .Down {
                                downvoteCount += 1
                            }
                            
                            transaction.updateData(["upvote-count": upvoteCount, "downvote-count": downvoteCount], forDocument: parentDocRef)
                            transaction.updateData(["status" : updatedStatus], forDocument: doc!.reference)
                        }
                    } catch {
                        
                    }
                    
                    return nil
                }) { (obj, error) in
                    if let error = error {
                        return promise.reject(error)
                    }
                    promise.fulfill_()
                }
            }
        }
    }
    
    func getVoteDirection(contentId: GenericID, collection: String) -> Promise<VoteDirection> {
        return Promise { promise in
            firstly {
                Services.userService.getCurrentUser()
            }.done { currentUser in
                let voteRef = Firestore.firestore().collection("\(collection)/\(contentId.value)/\(CollectionConstants.votesCollection)").whereField("voted-by", isEqualTo: currentUser.id!.value)
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
    
    func createAnswer(answer: Answer) -> Promise<Void> {
        return Promise { promise in
            let exercisePostRef = Firestore.firestore().document("/\(CollectionConstants.postsCollection)/\(answer.exercisePostId!)")
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    let exercisePostDoc = try transaction.getDocument(exercisePostRef).data()
                    guard var exercisePost = exercisePostDoc else { return nil }
                    
                    exercisePost["answers-count"] = (exercisePost["answers-count"] as! Int) + 1
                    transaction.updateData(exercisePost, forDocument: exercisePostRef)
                    let newAnswerRef = Firestore.firestore().collection(CollectionConstants.answerCollection).document()
                    var newAnswer = answer
                    newAnswer.id = AnswerID(newAnswerRef.documentID)
                    transaction.setData(DomainToFirebaseMapper.mapAnswer(from: newAnswer), forDocument: newAnswerRef)
                } catch { error
                    return promise.reject(error)
                }
                return nil
            }) { (obj, error) in
                if let error = error {
                    return promise.reject(error)
                }
                promise.fulfill_()
            }
        }
    }
       
    func createPost(post: ExercisePost) -> Promise<ExercisePost> {
        return Promise { promise in
            let newDocRef = Firestore.firestore().collection(CollectionConstants.postsCollection).document()
            let newPost = post
            newPost.id = ExercisePostID(newDocRef.documentID)
            
            newDocRef.setData(DomainToFirebaseMapper.mapExercisePost(post: newPost)) { error in
                if let error = error {
                    return promise.reject(error)
                }
            }
            
            if post.exercises.count > 0 {
                newDocRef.collection("exercises").addDocument(data: ["exercise": Firestore.firestore().document("/\(CollectionConstants.exerciseCollection)/\(post.exercises[0].id)")]) { error in
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
            if let tmp = cache[id!] {
                cache[id!] = nil
            }
            
            let db = Firestore.firestore()
            let docRef = db.collection(CollectionConstants.postsCollection).document(id!.value)
            
            docRef.setData(DomainToFirebaseMapper.mapExercisePost(post: newPost), merge:true) { err in
                if let err = err {
                    return promise.reject(err)
                } else {
                    promise.fulfill_()
                }
            }            
        }
    }
    
    //Deletes ExercisePost document, after first deleting it's images (if any), and corresponding answers, votes
    func deletePost(_ post: ExercisePost) -> Promise<Void> {
        return Promise { promise in
            
            let id = post.id
            
            //invalidate cache item
            if let tmp = cache[id!] {
                cache[id!] = nil
            }
            
            let docRef = Firestore.firestore().collection(CollectionConstants.postsCollection).document(id!.value)
            
            //setup execution the firestore delete answers request, delete votes request, and storage-delete-request in parallel
            var voidPromises = [Promise<Void>]()
            voidPromises.append(self.deleteAnswers(forPostWithId: id!))
            voidPromises.append(self.deleteVotes(forPostWithId: id!))
            
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
    func deleteAnswers(forPostWithId postId: ExercisePostID) -> Promise<Void> {
    
        return Promise { promise in
            let answersRef = Firestore.firestore().collection(CollectionConstants.answerCollection).whereField("exercise-post", isEqualTo: postId.value)
            answersRef.getDocuments { (answersSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var answersDeletePromises = [Promise<Void>]()
                for document in answersSnapshot!.documents {
                    answersDeletePromises.append(self.deleteAnswer(Answer(id: AnswerID(document.documentID), exercisePostId: postId)))
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
    func deleteAnswer(_ answer: Answer) -> Promise<Void> {
        return Promise { promise in
            let exercisePostRef = Firestore.firestore().document("/\(CollectionConstants.postsCollection)/\(answer.exercisePostId!)")
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    let exercisePostDoc = try transaction.getDocument(exercisePostRef).data()
                    guard var exercisePost = exercisePostDoc else { return nil }
                    
                    exercisePost["answers-count"] = (exercisePost["answers-count"] as! Int) - 1
                    transaction.updateData(exercisePost, forDocument: exercisePostRef)
                    let answerRef = Firestore.firestore().collection(CollectionConstants.answerCollection).document(answer.id!.value)
                    transaction.deleteDocument(answerRef)
                } catch { error
                    return promise.reject(error)
                }
                return nil
            }) { (obj, error) in
                if let error = error {
                    return promise.reject(error)
                }
                promise.fulfill_()
            }
        }
    }
    
    //Recursively deletes all the votes(documents) for a given PostID
    func deleteVotes(forPostWithId postId: ExercisePostID) -> Promise<Void> {
        return Promise { promise in
            let votesRef = Firestore.firestore().collection(CollectionConstants.postsCollection).document(postId.value)
                .collection(CollectionConstants.votesCollection)
            
            votesRef.getDocuments { (votesSnapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var votesDeletePromises = [Promise<Void>]()
                for document in votesSnapshot!.documents {
                    votesDeletePromises.append(self.deleteVote(forPostId: postId, withId: document.documentID))
                }
                
                firstly {
                    when(fulfilled: votesDeletePromises)
                }.done { _ in
                    return promise.fulfill_()
                }.catch { err in
                    print("deleteVotes Failed to delete all Votes for given Post:\(postId)")
                    return promise.reject(err)
                }
            }
        }
    }
    
    func deleteVote(forPostId postId: ExercisePostID, withId id: String) -> Promise<Void> {
        return Promise { promise in
            let voteRef = Firestore.firestore().collection(CollectionConstants.postsCollection).document(postId.value)
                .collection(CollectionConstants.votesCollection).document(id)
            
            voteRef.delete() { err in
                if let error = err {
                    print("deleteVote: failure delete vote: post=\(postId).vote=(\(id))")
                    return promise.reject(error)
                } else {
                    print("deleteVote: success delete vote: post=\(postId).vote=(\(id))")
                    return promise.fulfill_()
                }
            }
        }
    }
    
    func clearCache() {
        cache.empty()
    }
}
