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
import PromiseKit

class PostDetailViewController : UIViewController {
    
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postAuthorLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var numAnswersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addAnswerButton(_ sender: Any) {
        print("pressed add answer")
    }
    
    var post: ExercisePost?
    let exercisePostService = ExercisePostService()
        
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
        
        //post?.answers = FakeDataFactory.GetAnswersPosts(count: 5)
            
        firstly {
            //TODO: Replace with call to getAnswers(from: Number) which returns all answers since a specific "page length" (e.g. get first 10 posts by created date, scroll, when reached 8/10 posts fetch next 10 posts.
            
            //self.exercisePostService.getAnswers(forPostWithId : "yGL2u8fzSccPSghpke5w" )
            self.exercisePostService.getAnswers(forPostWithId : post?.id ?? "" )
        }.done { answers in
            self.post?.answers = answers
            self.post?.answersCount = answers.count
            self.tableView.reloadData()
        }.catch { error in
            //TODO: Do something when post fetching fails
        }
                
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName:K.Storyboard.detailedPostNibName , bundle: nil), forCellReuseIdentifier: K.Storyboard.detailedPostCellId)
        tableView.register(UINib(nibName:K.Storyboard.answerNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.answerCellId)
        
        tableView.separatorInset = UIEdgeInsets(top: -10,left: 0,bottom: 0,right: 0)
        
    }
}

enum SectionTypes: Int {
    case post = 0
    case answers = 1
}

extension PostDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //[0]Post, [1]=Answers
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SectionTypes.post.rawValue {
            return nil
        }
        return "\(post?.answersCount ?? 0) Answers"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SectionTypes.post.rawValue {
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
            cell.likeCountLabel.text = "\(post?.metrics.likes ?? 0)"
            
            return cell
             
        } else { //The answers
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.answerCellId, for: indexPath)
                as! AnswerPostCell
                    
            let answer = post?.answers[indexPath.row]
            cell.answerBodyLabel.text = answer?.text
            cell.answererNameLabel.text = answer?.createdBy?.information?.fullName
            cell.answererInfoLabel.text = answer?.createdBy?.information?.salutation
            
            cell.likeCountLabel.text = "\(answer?.upvotes ?? 0)"
            
            return cell
        }

    }
}

extension PostDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.section). \(indexPath.row)")
        
    }
}
