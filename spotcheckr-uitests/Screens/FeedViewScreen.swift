import XCTest

class FeedViewScreen: BaseScreen {
    func verifyOnFeedScreen() {
        XCTAssertTrue(app.collectionViews["FeedView"].waitForExistence(timeout: 5))
    }
}
