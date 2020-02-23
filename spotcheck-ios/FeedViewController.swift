import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import PromiseKit

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let exercisePostService = ExercisePostService()
    static let IMAGE_HEIGHT = 200
    
    var db: Firestore!
    
    var posts = [ExercisePost]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
         navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName:K.Storyboard.postNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.feedCellId)
        tableView.separatorInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)        
        
        getPosts()
    }
    
    func getPosts() {
        let completePostsDataSet = { ( argPosts: [ExercisePost]) in
            self.posts = argPosts
            //self.posts = NSArray(array: argPosts, copyItems: true) as! [ExercisePost]
            self.tableView.reloadData()
        }
        
        self.exercisePostService.getPosts(success: completePostsDataSet)
        
        //self.posts = FakeDataFactory.GetExercisePosts(count: 5)
        /*
        firstly {
            //TODO: Replace with call to getPosts(from: Number) which returns all posts since a specific "page length" (e.g. get first 10 posts by created date, scroll, when reached 8/10 posts fetch next 10 posts.
            //self.exercisePostService.getPost(withId: "dngi33GYXBQU2y6XxklQ")
            self.exercisePostService.getPost(withId: "egWXkAW15Uwn6ttuMBAS")
        }.done { post in
            self.posts = [post]
            //TODO: Since this is async, we would want the table view data source to refresh after it has been loaded. Maybe there is a way to make Posts an Observable that will automagically update after we set it?
            self.tableView.reloadData()
        }.catch { error in
            //TODO: Do something when post fetching fails
        }
        */
        

        /*
        firstly {
            self.exercisePostService.getPosts(success: completePostsDataSet)
            //self.exercisePostService.getPosts(success: refreshTableView)
        } .done { argPosts in
            self.posts = NSArray(array: argPosts, copyItems: true) as! [ExercisePost]
            print("ViewDidLoad==============================")
            print(self.posts)
            self.tableView.reloadData()
        } .catch { err in
            //do something
        }
        */
    }
    
    @objc func addTapped() {
        print("tapped Add Post")
        
        let createPostViewController = CreatePostViewController.create()
        
        self.present(createPostViewController, animated: true)
        //self.navigationController?.pushViewController(createPostViewController, animated: true)
    }
    
    @objc func refresh() {
        print("refresh")
        getPosts()
        refreshControl.endRefreshing()
    }
    
}


extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.feedCellId, for: indexPath)
            as! FeedPostCell
                
        cell.postLabel.text = posts[indexPath.row].title

        //this mocking logic if a post has an image attached
        let hasPhoto = Int.random(in: 0..<2)
        if hasPhoto == 1 {
            cell.photoHeightConstraint.constant = 0 //CGFloat(FeedViewController.IMAGE_HEIGHT)
            cell.photoView.isHidden = true
        }
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let postDetailViewController = PostDetailViewController.create(post: posts[indexPath.row])
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}

