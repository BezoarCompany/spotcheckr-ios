//
//  AppDelegate.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 1/21/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //FirebaseApp.configure()
        
        //setStartingViewController()
        
        return true
    }


    private func setStartingViewController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // User is signed in, proceed into the app
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        self.window?.rootViewController = baseViewController
        /*
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
            // User is signed in, proceed into the app
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let baseViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            self.window?.rootViewController = baseViewController
        } else {
            // No user is signed in, show options page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let baseViewController = storyboard.instantiateViewController(withIdentifier: "AuthOptionsViewController")
            self.window?.rootViewController = baseViewController
        }
        */
        self.window?.makeKeyAndVisible()
        
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

