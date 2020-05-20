import XCTest

class BaseTest: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launchArguments = ["enable-testing"]
    }

    func logout() {
        if BaseScreen(self).isLoggedIn() {
            SettingsScreen(self).tapSettingsTab()
                               .clickLogout()
        }
    }

    func loginIfNeeded(user: User) {
        if !BaseScreen(self).isLoggedIn() {
            LoginScreen(self).enterCredentials(emailAddress: user.emailAddress,
                                               password: user.password)
                .clickSignIn()
        }
        BaseScreen(self).verifyLoggedIn()
    }
}
