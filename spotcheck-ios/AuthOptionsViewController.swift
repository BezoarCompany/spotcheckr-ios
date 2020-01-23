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

class AuthOptionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @objc private func authenticationFinished() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        authenticationFinished()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        authenticationFinished()
    }
}

