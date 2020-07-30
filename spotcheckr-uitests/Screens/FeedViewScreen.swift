import XCTest

class FeedViewScreen: BaseScreen {
    func verifyOnFeedScreen() {
        XCTAssertTrue(app.collectionViews["FeedView"].cells.matching(identifier: "FeedCell").element.waitForExistence(timeout: 30))
    }
}
