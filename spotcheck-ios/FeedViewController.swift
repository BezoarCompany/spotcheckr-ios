import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit
import SVGKit
import MaterialComponents
import IGListKit


class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    static let IMAGE_HEIGHT = 200
    
    //The last snapshot of a post item. Used as a cursor in the query for the next group of posts
    var lastPostsSnapshot: DocumentSnapshot? = nil
    var posts = [ExercisePost]()
    var refreshControl = UIRefreshControl()

    let appBarViewController = UIElementFactory.getAppBar()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(appBarViewController.view)
        self.appBarViewController.didMove(toParent: self)

        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewEdittedPost), name: K.Notifications.ExercisePostEdits, object: nil)
        
        let plusImage = SVGKImage(named: "plus").uiImage.withRenderingMode(.alwaysTemplate)
        let addPostButton = MDCFloatingButton()
        addPostButton.setImage(plusImage, for: .normal)
        addPostButton.translatesAutoresizingMaskIntoConstraints = false
        addPostButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addPostButton.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        tableView.addSubview(addPostButton)
        
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: addPostButton.trailingAnchor, constant: 25).isActive = true
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: addPostButton.bottomAnchor, constant: 75).isActive = true
        addPostButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        addPostButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName:K.Storyboard.postNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.feedCellId)
        tableView.separatorInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)        
        
        getPosts(lastSnapshot: self.lastPostsSnapshot)
    }
    
    func getPosts(lastSnapshot: DocumentSnapshot?) {
        firstly {
            Services.exercisePostService.getPosts(lastPostSnapshot: self.lastPostsSnapshot)
        }.done { pagedResult in
            self.posts = pagedResult.posts//self.posts + pagedResult.posts
            self.lastPostsSnapshot = pagedResult.lastSnapshot
            self.tableView.reloadData()            
        }
        
    }
    
    @objc func addTapped() {
        let createPostViewController = CreatePostViewController.create(createdPostDetailClosure: self.viewPostHandler, diffedPostsDataClosure: self.diffedPostsHandler )
        
        self.present(createPostViewController, animated: true)
    }
    
    @objc func refresh() {
        self.posts = []
        getPosts(lastSnapshot: self.lastPostsSnapshot)
        refreshControl.endRefreshing()
    }
    
}

extension FeedViewController {
    
    //Renders the changes between self's posts[] and the arg's posts[]
    func diffedTableViewRenderer(argPosts: [ExercisePost]) {

      //new data comes in `argPosts`
      let results = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: self.posts, newArray: argPosts, option: .equality)

      self.posts = argPosts // set arg data into exiting array before updating tableview
      self.tableView.beginUpdates()
      self.tableView.deleteRows(at: results.deletes, with: .fade)
      self.tableView.insertRows(at: results.inserts, with: .automatic)
      //self.tableView.reloadRows(at: results.updates, with: .automatic)
      self.tableView.endUpdates()
    }


    //Will manipulate the data source for edits, and deletes. Then call the diffedTableViewRenderer to render the changes in the table view
    func diffedPostsHandler(diffType: DiffType, exercisePost: ExercisePost) {
      var newPostsCopy: [ExercisePost] = []
      
      var indexFound = -1
      for (i, val) in self.posts.enumerated() {
          if (val.id == exercisePost.id) {
              indexFound = i
          }
          
          newPostsCopy.append(val)
      }
              
      
      if(diffType == .add) {
          newPostsCopy.insert(exercisePost, at: 0)
      } else if (diffType == .edit) { //using Notification center to get the updated post. DiffTool isn't detecting changes b/c Old Post is same as New Posts, as if it were strongly refenced/changed.
          print("############# EDIT!!  \(posts[indexFound].title) ? \(newPostsCopy[indexFound].title)  : \(exercisePost.title)")
          print("index Found: \(indexFound)")
          
          newPostsCopy[indexFound] = exercisePost
        
          
          self.tableView.beginUpdates()
          let idxPath = IndexPath(row: indexFound, section: 0)
          self.tableView.reloadRows(at: [idxPath], with: .automatic)
          self.tableView.endUpdates()

          
      } else if (diffType == .delete) {
          newPostsCopy.remove(at: indexFound)
      }

      diffedTableViewRenderer(argPosts: newPostsCopy)
    }

    @objc func updateTableViewEdittedPost(notif: Notification) {
        print("hi from updateTableViewEdittedPost!")
        if let post = notif.userInfo?["post"] as? ExercisePost {
            diffedPostsHandler(diffType: .edit, exercisePost: post)
        }
    }
    
    func viewPostHandler(exercisePost: ExercisePost)  {
      let postDetailViewController = PostDetailViewController.create(post: exercisePost, diffedPostsDataClosure: self.diffedPostsHandler  )
      self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
      
}


extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.feedCellId, for: indexPath)
            as! FeedPostCell
        
        let pItem = posts[indexPath.row]
                
        cell.postLabel.text = pItem.title

        //this mocking logic if a post has an image attached
        if let hasPhoto = pItem.imagePath {
            cell.photoHeightConstraint.constant = CGFloat(FeedViewController.IMAGE_HEIGHT)
            
            // Set default image for placeholder
            let placeholderImage = UIImage(named:"squat1")!
            
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            let pathname = K.Firestore.Storage.IMAGES_ROOT_DIR + "/" + (pItem.imagePath ?? "")
            
            // Create a reference with an initial file path and name
            let storagePathReference = storage.reference(withPath: pathname)
            
            // Load the image using SDWebImage
            cell.photoView.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
            
            //Properties must be set everytime/every case so recycled cell values aren't being used
            cell.photoHeightConstraint.constant = CGFloat(FeedViewController.IMAGE_HEIGHT)
            cell.photoView.isHidden = false
            
        } else {
            cell.photoHeightConstraint.constant = 0
            cell.photoView.isHidden = true
        } 
        
        cell.postBodyLabel.text = pItem.description

        //remove the default highlight which has shining look-gloss effect with the dark theme
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        cell.directionalLayoutMargins = .zero
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postDetailViewController = PostDetailViewController.create(post: posts[indexPath.row], diffedPostsDataClosure: self.diffedPostsHandler )
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
