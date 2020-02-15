import PromiseKit

protocol ExercisePostProtocol {
    func getPost(withId id: String) -> Promise<ExercisePost>
    func getPosts(success: @escaping ([ExercisePost])->Void) -> Promise<[ExercisePost]>
    func getAnswers(forUserWithId userId: String) -> Promise<[Answer]>
}
