import FirebaseAuth
import PromiseKit
import Foundation

class AuthenticationService: AuthenticationProtocol {
    func sendResetPasswordEmail(emailAddress: String) -> Promise<Void> {
        return Promise { promise in
            Auth.auth().sendPasswordReset(withEmail: emailAddress) { error in
                return error != nil ? promise.reject(error!) : promise.fulfill_()
            }
        }
    }
    
    func signUp(emailAddress: String, password: String, isTrainer: Bool) -> Promise<Void> {
        return Promise { promise in
            Auth.auth().createUser(withEmail: emailAddress, password: password) {
                authResult, error in
                guard  authResult != nil else {
                    return promise.reject(error!)
                }
                let user = isTrainer ? Trainer(id: UserID((authResult?.user.uid)!)) : User(id: UserID((authResult?.user.uid)!))
                
                firstly {
                    Services.userService.createUser(user: user)
                }.catch { error in
                    //TODO: Handle error with retry logic.
                    return promise.reject(error)
                }.finally {
                    return promise.fulfill_()
                }
            }
        }
    }
    
    func anonymousSignUp() -> Promise<Void> {
        return Promise { promise in
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    promise.reject(error)
                }
                
                let user = User(id: UserID((result?.user.uid)!))
                user.isAnonymous = true
                user.dateCreated = Date()
                
                firstly {
                    Services.userService.createUser(user: user)
                }.catch { error in
                    return promise.reject(error)
                }.finally {
                    return promise.fulfill_()
                }
            }
        }
    }
    
    func signIn(emailAddress: String, password: String) -> Promise<Void> {
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
