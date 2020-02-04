import FirebaseAuth

class AuthenticationService: AuthenticationProtocol {
    public func signIn(emailAddress: String, password: String) {
        Auth.auth().signIn(withEmail: emailAddress, password: password) {
            authResult, error in
            //TODO: Do something with the success/failure result.
        }
    }
}
