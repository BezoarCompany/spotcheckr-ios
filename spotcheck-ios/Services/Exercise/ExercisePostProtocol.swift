import PromiseKit
import FirebaseFirestore
import FirebaseFirestoreSwift


typealias ClosureToExercisepostPromiseType = ()->Promise<ExercisePost>

struct PaginatedGetPostsResult {
    let posts: [ExercisePost]
    let lastSnapshot: DocumentSnapshot?
}

protocol ExercisePostProtocol {
    func getPost(withId id: ExercisePostID) -> Promise<ExercisePost>
    func getPosts(limit: Int, lastPostSnapshot: DocumentSnapshot?) -> Promise<PaginatedGetPostsResult>
    func getPosts(forUser user: User) -> Promise<[ExercisePost]>
    func getExercises(forPostWithId postId: ExercisePostID) -> Promise<[Exercise]>
    func getExercises() -> Promise<[String:Exercise]>
    func getAnswers(byUserWithId userId: UserID) -> Promise<[Answer]>
    func getAnswers(forPostWithId postId: ExercisePostID) -> Promise<[Answer]>
    func voteContent(contentId: GenericID, userId: UserID, direction: VoteDirection) -> Promise<Void>
    func getVoteDirection(contentId: GenericID, collection: String) -> Promise<VoteDirection>
    
    func createPost(post: ExercisePost) -> Promise<ExercisePost>
    func createAnswer(answer: Answer) -> Promise<Void>
        
    func updatePost(post: ExercisePost) -> Promise<Void>
    
    func deletePost(_ post: ExercisePost) -> Promise<Void>
    func deleteAnswers(forPostWithId postId: ExercisePostID) -> Promise<Void>
    func deleteAnswer(_ answer: Answer) -> Promise<Void>
    
    func deleteVotes(forPostWithId postId: ExercisePostID) -> Promise<Void>
    func deleteVote(forPostId postId: ExercisePostID, withId id: String) -> Promise<Void>
    
    func clearCache() -> Void
}
