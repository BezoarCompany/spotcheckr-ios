import PromiseKit
import FirebaseFirestore
import FirebaseFirestoreSwift


typealias ClosureToExercisepostPromiseType = ()->Promise<ExercisePost>

struct PaginatedGetPostsResult {
    let posts: [ExercisePost]
    let lastSnapshot: DocumentSnapshot?
}

protocol ExercisePostProtocol {
    func getPost(withId id: String) -> Promise<ExercisePost>
    func getPosts(limit: Int, lastPostSnapshot: DocumentSnapshot?) -> Promise<PaginatedGetPostsResult>
    func getPosts(forUser user: User) -> Promise<[ExercisePost]>
    func getUpvoteCount(forPostWithId postId: String, collection: String) -> Promise<Int>
    func getDownvoteCount(forPostWithId postId: String, collection: String) -> Promise<Int>
    func getViewsCount(forPostWithId postId: String) -> Promise<Int>
    func getExercises(forPostWithId postId: String) -> Promise<[Exercise]>
    func getExercises() -> Promise<[String:Exercise]>
    func getAnswers(byUserWithId userId: String) -> Promise<[Answer]>
    func getAnswers(forPostWithId postId: String) -> Promise<[Answer]>
    func votePost(postId: String, userId: String, direction: VoteDirection) -> Promise<Void>
    func voteAnswer(answerId: String, userId: String, direction: VoteDirection) -> Promise<Void>
    func getVoteDirection(id: String, collection: String) -> Promise<VoteDirection>
    
    func createPost(post: ExercisePost) -> Promise<ExercisePost>
    func createAnswer(answer: Answer) -> Promise<Void>
        
    func updatePost(post: ExercisePost) -> Promise<Void>
    
    func deletePost(_ post: ExercisePost) -> Promise<Void>
    func deleteAnswers(forPostWithId postId: String) -> Promise<Void>
    func deleteAnswer(withId id: String) -> Promise<Void>
    
    func deleteVotes(forPostWithId postId: String) -> Promise<Void>
    func deleteVote(forPostId postId: String, withId id: String) -> Promise<Void>
    
    func clearCache() -> Void
}
