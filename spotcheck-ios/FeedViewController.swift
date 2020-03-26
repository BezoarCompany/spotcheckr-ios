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
    static let IMAGE_HEIGHT = 200
    
    //The last snapshot of a post item. Used as a cursor in the query for the next group of posts
    var lastPostsSnapshot: DocumentSnapshot? = nil
    var posts = [ExercisePost]()
    var refreshControl = UIRefreshControl()
    var activityIndicator = UIElementFactory.getActivityIndicator()
    var initialLoadActivityIndicator = UIElementFactory.getActivityIndicator()
    let appBarViewController = UIElementFactory.getAppBar()
    let addPostButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setImage(Images.plus, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let feedView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var currentUser: User?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appBarViewController.didMove(toParent: self)

        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewEdittedPost), name: K.Notifications.ExercisePostEdits, object: nil)
        
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            self.currentUser = user
        }
    
        addSubviews()
        initFeedView()
        initRefreshControl()
        initAddPostButton()
        applyConstraints()
        self.initialLoadActivityIndicator.startAnimating()
        firstly {
            getPosts(lastSnapshot: self.lastPostsSnapshot)
        }.done {
            self.initialLoadActivityIndicator.stopAnimating()
        }
    }
    
    func getPosts(lastSnapshot: DocumentSnapshot?) -> Promise<Void> {
        return Promise { promise in
            
            firstly {
                Services.exercisePostService.getPosts(lastPostSnapshot: self.lastPostsSnapshot)
            }.done { pagedResult in
                self.posts = pagedResult.posts
                self.lastPostsSnapshot = pagedResult.lastSnapshot
                self.feedView.reloadData()
                return promise.fulfill_()         
            }
        }
    }
    
    func initFeedView() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 1)
        feedView.collectionViewLayout = layout
        feedView.delegate = self
        feedView.dataSource = self
        feedView.register(FeedCell.self, forCellWithReuseIdentifier: "Cell")
        feedView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
    }
    
    func addSubviews() {
        view.addSubview(feedView)
        view.addSubview(appBarViewController.view)
        feedView.addSubview(initialLoadActivityIndicator)
        feedView.addSubview(addPostButton)
        refreshControl.addSubview(activityIndicator)
        feedView.addSubview(refreshControl)
    }
    
    func initRefreshControl() {
        refreshControl.tintColor = .clear
        refreshControl.backgroundColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: UIControl.Event.valueChanged)
    }
    
    func initAddPostButton() {
        addPostButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            initialLoadActivityIndicator.centerXAnchor.constraint(equalTo: feedView.centerXAnchor),
            initialLoadActivityIndicator.centerYAnchor.constraint(equalTo: feedView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: refreshControl.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: refreshControl.centerYAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: addPostButton.trailingAnchor, constant: 25),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: addPostButton.bottomAnchor, constant: 75),
            addPostButton.widthAnchor.constraint(equalToConstant: 64),
            addPostButton.heightAnchor.constraint(equalToConstant: 64),
            feedView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor),
            //TODO: How to get the tab bar then assign to its top anchor?
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: feedView.bottomAnchor, constant: 55),
            feedView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: feedView.trailingAnchor),
        ])
    }
    
    @objc func addTapped() {
        let createPostViewController = CreatePostViewController.create(createdPostDetailClosure: self.viewPostHandler, diffedPostsDataClosure: self.diffedPostsHandler )
        
        self.present(createPostViewController, animated: true)
    }
    
    @objc func refreshPosts() {
        refreshControl.beginRefreshing()
        activityIndicator.startAnimating()

        self.posts = []
        self.feedView.reloadData() 
        firstly {
            getPosts(lastSnapshot: self.lastPostsSnapshot)
        }.done {
            self.perform(#selector(self.finishRefreshing), with: nil, afterDelay: 0.1)
        }
    }

    @objc func finishRefreshing() {
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
}

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
        for: indexPath) as! FeedCell
        cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
        cell.setCellWidth(width: view.frame.width)
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        cell.headerLabel.text = post.title
        cell.subHeadLabel.text = "\(post.dateCreated?.toDisplayFormat() ?? "") • \(post.answersCount) Answers"
        if post.imagePath != nil {
            // Set default image for placeholder
            let placeholderImage = UIImage(named:"squat1")!
            
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            let pathname = K.Firestore.Storage.IMAGES_ROOT_DIR + "/" + (post.imagePath ?? "")
            
            // Create a reference with an initial file path and name
            let storagePathReference = storage.reference(withPath: pathname)
            
            // Load the image using SDWebImage
            cell.media.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
            
            cell.setConstraintsWithMedia()
        }
        cell.supportingTextLabel.text = post.description
        cell.postId = post.id
        cell.votingUserId = currentUser?.id
        cell.voteDirection = post.metrics.currentVoteDirection
        cell.adjustVotingControls()
        cell.cornerRadius = 0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        viewPostHandler(exercisePost: post)
    }
}

extension FeedViewController {
    //Renders the changes between self's posts[] and the arg's posts[]
    func diffedTableViewRenderer(argPosts: [ExercisePost]) {
        //new data comes in `argPosts`
        let results = ListDiffPaths(fromSection: 0, toSection: 0, oldArray: self.posts, newArray: argPosts, option: .equality)

        self.posts = argPosts // set arg data into exiting array before updating tableview
        self.feedView.performBatchUpdates({
        self.feedView.deleteItems(at: results.deletes)
        self.feedView.insertItems(at: results.inserts)
      })
      //TODO: Do fade animation (?) for deletes and automatic for insert
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
      }
      else if (diffType == .edit) { //using Notification center to get the updated post. DiffTool isn't detecting changes b/c Old Post is same as New Posts, as if it were strongly refenced/changed.
        print("############# EDIT!!  \(posts[indexFound].title) ? \(newPostsCopy[indexFound].title)  : \(exercisePost.title)")
        print("index Found: \(indexFound)")
          
        newPostsCopy[indexFound] = exercisePost
        feedView.performBatchUpdates({
            let idxPath = IndexPath(row: indexFound, section: 0)
            self.feedView.reloadItems(at: [idxPath])
        })
        
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
        let postDetailViewController = PostDetailViewController.create(postId: exercisePost.id, diffedPostsDataClosure: self.diffedPostsHandler  )
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
