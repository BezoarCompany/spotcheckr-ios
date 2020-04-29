import UIKit
import Firebase
import FirebaseUI
import DropDown
import IQKeyboardManagerSwift
import PromiseKit
import SwiftyPlistManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEVEL
            print("########################## DEVELOPMENT ##########################")
        #elseif STAGE
            print("########################## STAGING ##########################")
        #else
            print("########################## PROD-Release ##########################")
        #endif

        styleNavigationBar()
        styleTabBar()
        configureServices()
        setStartingViewController()
        DropDown.startListeningToKeyboard()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        return true
    }

    private func styleNavigationBar() {
        UINavigationBar.appearance().barTintColor = ApplicationScheme.instance.containerScheme.colorScheme.primaryColor
        UINavigationBar.appearance().tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: ApplicationScheme.instance.containerScheme.typographyScheme.headline6,
            NSAttributedString.Key.foregroundColor: ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        ]
    }

    private func styleTabBar() {
        UITabBar.appearance().barTintColor = ApplicationScheme.instance.containerScheme.colorScheme.primaryColor
        UITabBar.appearance().tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
    }

    private func configureServices() {
        FirebaseApp.configure()
        let plistFiles = ["Preferences"]
        #if DEVEL
            Analytics.setAnalyticsCollectionEnabled(false)
            SwiftyPlistManager.shared.start(plistNames: plistFiles, logging: true)
        #else
            SwiftyPlistManager.shared.start(plistNames: plistFiles, logging: false)
        #endif
    }

    private func setStartingViewController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let currentUser = Auth.auth().currentUser
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = currentUser != nil ?
                                 storyboard.instantiateViewController(withIdentifier: K.Storyboard.MainTabBarControllerId) :
                                 storyboard.instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId)
        self.window?.rootViewController = baseViewController
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state
        // information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //checkConfiguration()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
