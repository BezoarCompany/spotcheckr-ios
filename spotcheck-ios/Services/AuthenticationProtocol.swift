import PromiseKit

protocol AuthenticationProtocol {
    func signIn(emailAddress: String, password: String) -> Promise<Void>
    func signUp(emailAddress: String, password: String, isTrainer: Bool) -> Promise<Void>
    func sendResetPasswordEmail(emailAddress: String) -> Promise<Void>
}
