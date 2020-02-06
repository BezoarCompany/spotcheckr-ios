//
//  ProfileViewController.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 1/22/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import Foundation
import Firebase

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("@ ProfileViewController")
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        // Return to the initial login screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId )
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
}
