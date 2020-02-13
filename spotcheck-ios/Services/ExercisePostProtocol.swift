import PromiseKit

protocol ExercisePostProtocol {
    func getPost(withId id: String) -> Promise<ExercisePost>
    func getPosts(forUserWithId userId: String) -> Promise<[ExercisePost]>
    func getAnswers(forUserWithId userId: String) -> Promise<[Answer]>
}
