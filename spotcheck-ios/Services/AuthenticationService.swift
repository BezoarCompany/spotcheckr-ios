import FirebaseAuth
import PromiseKit

class AuthenticationService: AuthenticationProtocol {
    public func signIn(emailAddress: String, password: String) -> Promise<Void> {
        return Promise { promise in
            Auth.auth().signIn(withEmail: emailAddress, password: password) {
                authResult, error in
                guard authResult != nil else {
                    return promise.reject(error!)
                }
                return promise.fulfill_()
            }
        }
    }
}
