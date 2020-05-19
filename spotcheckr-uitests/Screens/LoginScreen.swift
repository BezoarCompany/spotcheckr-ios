import XCTest

class LoginScreen: BaseScreen {
    struct Buttons {
        var signUpButton: XCUIElement
        var signInButton: XCUIElement
        var skipButton: XCUIElement
        var forgotPasswordButton: XCUIElement
    }

    struct TextFields {
        var emailAddressTextField: XCUIElement
        var passwordTextField: XCUIElement
    }

    var buttons: Buttons?
    var textFields: TextFields?

    override init(_ xctc: XCTestCase) {
        super.init(xctc)
        buttons = Buttons(signUpButton: app.buttons["Sign Up"],
                          signInButton: app.buttons["Sign In"],
                          skipButton: app.buttons["Skip Sign Up"],
                          forgotPasswordButton: app.buttons["Forgot Password?"])
        textFields = TextFields(emailAddressTextField: app.textFields["Email Address"],
                                passwordTextField: app.secureTextFields["Password"])
    }

    func enterCredentials(emailAddress: String, password: String) -> LoginScreen {
        textFields?.emailAddressTextField.tap()
        textFields?.emailAddressTextField.typeText(emailAddress)
        app.keyboards.buttons["Next:"].tap()
        textFields?.passwordTextField.typeText(password)
        app.keyboards.buttons["Done"].tap()
        return self
    }

    func clickSignIn() {
        buttons?.signInButton.tap()
    }

    func goToSignUp() {
        buttons?.signUpButton.tap()
    }

    func goToForgotPassword() {
        buttons?.forgotPasswordButton.tap()
    }
}
