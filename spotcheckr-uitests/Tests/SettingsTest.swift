class SettingsTest: BaseTest {
    override func setUp() {
        super.setUp()
        app.launch()
        loginIfNeeded(user: Users.testUser)
    }
    
    func testLogout() {
        BaseScreen(self).tapSettingsTab().clickLogout()
    }
}
