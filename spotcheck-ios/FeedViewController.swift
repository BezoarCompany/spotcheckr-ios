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
    var posts = [ExercisePost]()
    var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return control
    }()
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
        getPosts()
    }
    
    func getPosts() {
        let completePostsDataSet = { ( argPosts: [ExercisePost]) in
            self.posts = argPosts
            self.feedView.reloadData()
        }
        
        Services.exercisePostService.getPosts(success: completePostsDataSet)
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
        feedView.addSubview(addPostButton)
    }
    
    func initRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    func initAddPostButton() {
        addPostButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    func applyConstraints() {
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: addPostButton.trailingAnchor, constant: 25).isActive = true
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: addPostButton.bottomAnchor, constant: 75).isActive = true
        addPostButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        addPostButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        feedView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor).isActive = true
        feedView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        feedView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: feedView.trailingAnchor).isActive = true
    }
    
    @objc func addTapped() {
        let createPostViewController = CreatePostViewController.create(createdPostDetailClosure: self.viewPostHandler, diffedPostsDataClosure: self.diffedPostsHandler )
        
        self.present(createPostViewController, animated: true)
    }
    
    @objc func refresh() {
        getPosts()
        refreshControl.endRefreshing()
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
        cell.setCellWidth(width: view.frame.width)
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        cell.headerLabel.text = post.title
        cell.subHeadLabel.text = post.dateCreated?.toDisplayFormat()
        if post.imagePath != nil {
            cell.media.image = UIImage(named:"squat1")! //temp
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
        
          
//          self.tableView.beginUpdates()
//          let idxPath = IndexPath(row: indexFound, section: 0)
//          self.tableView.reloadRows(at: [idxPath], with: .automatic)
//          self.tableView.endUpdates()

          
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
