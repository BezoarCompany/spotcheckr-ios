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

class FeedViewController: UITableViewController, PostsService {
    
    var db: Firestore!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("@FeedViewController")
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        tableView.rowHeight = 80
        tableView.allowsMultipleSelectionDuringEditing = false
        
        db.collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents{
                                        
                    print("\(document.documentID)")
                    print("\(document.documentID) => \(document.data())")
                    
                    //closure success will run this, saving the context of all the external variables when we pass it
                    var createPost = { (argPost: Post?) -> Post? in
                        print(argPost!.question , " by:" , argPost!.authorName)
                        if let post = argPost {
                            self.posts.append(post)
                            self.tableView.reloadData()
                        }
                        return argPost
                    }
                    self.fetchPost(withId: document.documentID, completion: createPost)
                    
                }
            }
            
        }
    }
    
    
    // MARK: UITableView Delegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "----"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // MARK: Populating table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        
        cell.textLabel?.text = posts[indexPath.row].question
        cell.detailTextLabel?.text = posts[indexPath.row].authorName
        
        return cell
    }
}
