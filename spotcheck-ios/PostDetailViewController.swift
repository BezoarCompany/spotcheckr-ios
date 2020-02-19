//
//  PostDetailViewController.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 2/9/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class PostDetailViewController : UIViewController {
    
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postAuthorLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var numAnswersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var post: ExercisePost?
        
        /*
 Post(postId: "a", authorId: "1", authorName: "Miguel", createdAt: "2/2/2020", updatedAt: "2/2/2020", question: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in")
    */
    static func create(post: ExercisePost?) -> PostDetailViewController {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let postDetailViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.PostDetailViewControllerId) as! PostDetailViewController
        
        postDetailViewController.post = post
        return postDetailViewController
        
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        post?.answers = FakeDataFactory.GetAnswersPosts(count: 5)
                
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName:K.Storyboard.detailedPostNibName , bundle: nil), forCellReuseIdentifier: K.Storyboard.detailedPostCellId)
        tableView.register(UINib(nibName:K.Storyboard.answerNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.answerCellId)
        
    }
}


extension PostDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return post?.answers.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //The original question/post
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.detailedPostCellId, for: indexPath)
            as! DetailedPostCell
            
            cell.postTitleLabel.text = post?.title
            cell.posterNameLabel.text = (post?.createdBy?.information?.fullName ?? "Anonymous")
            cell.posterDetailLabel.text = "Tool extraordinaire"
            
            cell.postBodyLabel.text = post?.description
            return cell
             
        } else { //The answers
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.answerCellId, for: indexPath)
                as! AnswerPostCell
                    
            
            cell.answerBodyLabel.text = post?.answers[indexPath.row].text
            cell.answererNameLabel.text = post?.answers[indexPath.row].createdBy?.information?.fullName
            cell.answererInfoLabel.text = post?.answers[indexPath.row].createdBy?.information?.salutation
                   
            return cell
        }

    }
}

extension PostDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.section). \(indexPath.row)")
        
    }
}
