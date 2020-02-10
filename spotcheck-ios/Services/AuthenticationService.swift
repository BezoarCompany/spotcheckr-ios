import FirebaseAuth
import PromiseKit
import Foundation

class AuthenticationService: AuthenticationProtocol {
    private let userService = UserService()
    
    func sendResetPasswordEmail(emailAddress: String) -> Promise<Void> {
        return Promise { promise in
            Auth.auth().sendPasswordReset(withEmail: emailAddress) { error in
                return error != nil ? promise.reject(error!) : promise.fulfill_()
            }
        }
    }
    
    func signUp(emailAddress: String, password: String) -> Promise<Void> {
        return Promise { promise in
            Auth.auth().createUser(withEmail: emailAddress, password: password) {
                authResult, error in
                guard  authResult != nil else {
                    return promise.reject(error!)
                }
                
                firstly {
                    self.userService.createUser(id: (authResult?.user.uid)!)
                }.catch { error in
                    return promise.reject(error)
                }.finally {
                    return promise.fulfill_()
                }
            }
        }
    }
    
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
