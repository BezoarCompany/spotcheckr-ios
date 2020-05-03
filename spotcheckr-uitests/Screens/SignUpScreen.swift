import XCTest

class SignUpScreen: BaseScreen {
    struct Buttons {
        var createAccountButton: XCUIElement
        var backToLoginButton: XCUIElement
    }
    
    var buttons: Buttons?
    
    override init(_ xctc: XCTestCase) {
        super.init(xctc)
        buttons = Buttons(createAccountButton: app.buttons["Create Account"],
                          backToLoginButton: app.buttons["Have an Account? Log In"])
    }
    
    func verifyOnScreen() {
        XCTAssertTrue(buttons?.createAccountButton.exists ?? false, "Not on sign up screen.")
    }
    
    func goToSignInScreen() -> SignUpScreen {
        buttons?.backToLoginButton.tap()
        return self
    }
}
