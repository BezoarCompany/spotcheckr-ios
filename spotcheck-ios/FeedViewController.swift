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
    
    @IBOutlet weak var tableView: UITableView!
    
    var db: Firestore!
    var posts: [Post] = [
        Post(postId: "a", authorId: "1", authorName: "Miguel", createdAt: "2/2/2020", updatedAt: "2/2/2020", question: "Why is the sky blue?"),
        Post(postId: "b", authorId: "2", authorName: "Nitish", createdAt: "2/2/2020", updatedAt: "2/2/2020", question: "Does gymming attract pussy cats?"),
        Post(postId: "c", authorId: "1", authorName: "Miguel", createdAt: "2/2/2020", updatedAt: "2/2/2020", question: "Will the Chiefs win the superbowl?")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("@FeedViewController")
                
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName:K.Storyboard.postNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.feedCellId)
    }
}


extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.feedCellId, for: indexPath)
            as! PostCell
                
        cell.postLabel.text = posts[indexPath.row].question
        cell.authorLabel.text = posts[indexPath.row].authorName
        //cell.textLabel?.text = posts[indexPath.row].question
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

