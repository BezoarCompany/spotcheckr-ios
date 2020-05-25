import FirebaseFirestore

class LoginTest: BaseTest {
    override func setUp() {
        super.setUp()
        app.launch()
    }

    func testLogin() {
        logout()
        LoginScreen(self).enterCredentials(emailAddress: Users.testUser.emailAddress,
                                         password: Users.testUser.password)
                        .clickSignIn()
        FeedViewScreen(self).verifyOnFeedScreen()
    }

    func testAnonymousSignUp() {
        logout()
        LoginScreen(self).clickAnonymousSignUp()
        FeedViewScreen(self).verifyOnFeedScreen()
    }
}
