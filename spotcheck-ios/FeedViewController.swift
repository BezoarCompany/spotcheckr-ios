//
//  FeedViewController.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 1/22/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import Foundation

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class FeedViewController: UIViewController, PostsService {
    
    var db: Firestore!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("@FeedViewController")
                
    }
    
}
