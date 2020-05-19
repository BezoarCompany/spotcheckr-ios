import XCTest

class SettingsScreen: BaseScreen {
    struct Cells {
        var logoutCell: XCUIElement
    }

    var cells: Cells?

    override init(_ xctc: XCTestCase) {
        super.init(xctc)
        cells = Cells(logoutCell: app.collectionViews.cells["LogOutCell"])
    }

    func clickLogout() {
        cells?.logoutCell.tap()
    }
}
