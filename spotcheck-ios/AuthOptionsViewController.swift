//
//  AuthOptionsViewController.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 1/22/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import MaterialComponents
import MaterialComponents.MaterialButtons_Theming

class AuthOptionsViewController: UIViewController {

    @IBOutlet weak var SignUpButton: MDCButton!
    @IBOutlet weak var LogInButton: MDCButton!
    
    @IBOutlet weak var SpotcheckHeadline: UILabel!
    @IBOutlet weak var SpotcheckSubtitle: UILabel!
    @IBOutlet weak var ConnectWithGoogleButton: MDCButton!
    @IBOutlet weak var ConnectWithFacebookButton: MDCButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        SignUpButton.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        LogInButton.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        SpotcheckHeadline.font = ApplicationScheme.instance.containerScheme.typographyScheme.headline4
        SpotcheckSubtitle.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle1
        ConnectWithGoogleButton.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        ConnectWithFacebookButton.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        
    }

    @objc private func authenticationFinished() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
}

