import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import PromiseKit

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let exercisePostService = ExercisePostService()
    var db: Firestore!
    
    var posts = [ExercisePost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("@FeedViewController")
       let user1 = User(id: "1")
       user1.information = Identity(firstName: "Miguel", lastName: "Paysan")
       let user2 = User(id: "2")
       user2.information = Identity(firstName: "Nitish", lastName: "Sachar")
       self.posts = [
           ExercisePost(id: "a", title: "Who sells sea shells by the sea shore?", description: "Does Miguel?", createdBy: user2),
           ExercisePost(id: "b", title: "Does gymming attract pussy cats?", description: "cuz i like pussy cats", createdBy: user1),
           ExercisePost(id: "c", title: "Will the Chiefs win the superbowl?", description: "Likr OMH beckk wtfa. Lorem ipsum, squirtle squirtle squirtle.", createdBy: user1)
       ]
//        firstly {
//            //TODO: Replace with call to getPosts(from: Number) which returns all posts since a specific "page length" (e.g. get first 10 posts by created date, scroll, when reached 8/10 posts fetch next 10 posts.
//            self.exercisePostService.getPost(withId: "dngi33GYXBQU2y6XxklQ")
//        }.done { post in
//            self.posts = [post]
//            //TODO: Since this is async, we would want the table view data source to refresh after it has been loaded. Maybe there is a way to make Posts an Observable that will automagically update after we set it?
//        }.catch { error in
//            //TODO: Do something when post fetching fails
//        }
        
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
            as! FeedPostCell
                
        cell.postLabel.text = posts[indexPath.row].title
        cell.authorNameLabel.text = posts[indexPath.row].createdBy.information?.fullName
        cell.authorTaglineLabel.text = "Tool default"
        
        cell.upvoteCounts.text = "\(posts[indexPath.row].metrics.upvotes)"
        cell.answersLabel.text = "\(posts[indexPath.row].answers.count) answers"
        
        //cell.textLabel?.text = posts[indexPath.row].question
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

