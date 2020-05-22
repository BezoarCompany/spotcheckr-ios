import XCTest

class BaseScreen {
    let app = XCUIApplication()
    let xctcRef: XCTestCase

    init(_ xctc: XCTestCase) {
        xctcRef = xctc
    }

    func isLoggedIn() -> Bool {
        return app.buttons["Feed"].firstMatch.exists
    }

    func tapFeedTab() -> FeedViewScreen {
        app.buttons["Feed"].firstMatch.tap()
        return FeedViewScreen(xctcRef)
    }

    func tapProfileTab() -> ProfileScreen {
        app.buttons["Profile"].firstMatch.tap()
        return ProfileScreen(xctcRef)
    }

    func tapSettingsTab() -> SettingsScreen {
        app.buttons["Settings"].firstMatch.tap()
        return SettingsScreen(xctcRef)
    }

    func verifyLoggedIn() {
        app.buttons["Feed"].waitForExistence(timeout: 5)
    }
}
