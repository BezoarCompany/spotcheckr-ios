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
    
    var posts = [ExercisePost]()
    var refreshControl = UIRefreshControl()
    var activityIndicator = UIElementFactory.getActivityIndicator()
    let appBarViewController = UIElementFactory.getAppBar()
    
    //The last snapshot of a post item. Used as a cursor in the query for the next group of posts
    var lastPostsSnapshot: DocumentSnapshot? = nil
    var isFetchingMore = false
    var endReached = false
    var cellHeights = [IndexPath: CGFloat]() //used to remember cell heights to prevent recalc of heights which causes jumpy scrolling
    
    let cellHeightEstimate = 185.0 // Getting a good approximate is essential to prevent collectionView from jumpy behavior due to reloadData
    let cellEstimatedSize: CGSize = {
        let w = UIScreen.main.bounds.size.width
        let h = CGFloat(185)
        let size = CGSize(width: w, height: h)
        return size
    }()
    
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
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
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
        
        refreshPosts()
    }
    
    func fetchMorePosts(lastSnapshot: DocumentSnapshot?) -> Promise<[ExercisePost]> {
        print("@fetchMorePosts \(lastSnapshot)")
        return Promise { promise in
            
            firstly {
                Services.exercisePostService.getPosts(limit: 10, lastPostSnapshot: self.lastPostsSnapshot)
            }.done { pagedResult in
                self.lastPostsSnapshot = pagedResult.lastSnapshot
                let newPosts = pagedResult.posts
                return promise.fulfill(newPosts)
                
            }.catch { err in
                return promise.reject(err)
            }
        }
    }
    
    func initFeedView() {
        layout.estimatedItemSize = cellEstimatedSize
        feedView.collectionViewLayout = layout
        feedView.delegate = self
        feedView.dataSource = self
        feedView.register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.cellId)
        feedView.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.cellId)
        feedView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
    }
    
    func addSubviews() {
        view.addSubview(feedView)
        view.addSubview(appBarViewController.view)
        feedView.addSubview(addPostButton)
        refreshControl.addSubview(activityIndicator)
        feedView.addSubview(refreshControl)
    }
    
    func initRefreshControl() {
        refreshControl.tintColor = .white
        let fontColorAttr = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: fontColorAttr)
        refreshControl.backgroundColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: UIControl.Event.valueChanged)
    }
    
    func initAddPostButton() {
        addPostButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    func applyConstraints() {
        let safeAreaLayout = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: refreshControl.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: refreshControl.centerYAnchor),
            addPostButton.trailingAnchor.constraint(equalTo: safeAreaLayout.trailingAnchor, constant: -25),
            addPostButton.bottomAnchor.constraint(equalTo: safeAreaLayout.bottomAnchor, constant: -75),
            addPostButton.widthAnchor.constraint(equalToConstant: 64),
            addPostButton.heightAnchor.constraint(equalToConstant: 64),
            feedView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor),
            //TODO: How to get the tab bar then assign to its top anchor?
            feedView.bottomAnchor.constraint(equalTo: safeAreaLayout.bottomAnchor, constant: -70),
            feedView.leadingAnchor.constraint(equalTo: safeAreaLayout.leadingAnchor),
            feedView.trailingAnchor.constraint(equalTo: safeAreaLayout.trailingAnchor)
        ])
    }
    
    @objc func addTapped() {
        let createPostViewController = CreatePostViewController.create(createdPostDetailClosure: self.viewPostHandler, diffedPostsDataClosure: self.diffedPostsHandler )
        
        self.present(createPostViewController, animated: true)
    }
    
    @objc func refreshPosts() {
        
        self.lastPostsSnapshot = nil
        self.endReached = false
        Services.exercisePostService.clearCache()
        
        firstly {
            fetchMorePosts(lastSnapshot: nil)
        }.done { posts in
            DispatchQueue.main.async {
                self.posts = posts
                self.feedView.reloadData()
                self.perform(#selector(self.finishRefreshing), with: nil, afterDelay: 0.1)
            }
        }
    }

    @objc func finishRefreshing() {
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
}

// Mark: Collection View Data Source
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return posts.count
        }
        //Section for the Loading cell will only appear for duration of batch loading, via the isFetchingMore flag
        return isFetchingMore ? 1 : 0
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.cellId,
            for: indexPath) as! LoadingCell
            cell.layer.masksToBounds = true
            cell.activityIndicator.startAnimating()
            return cell
        }
        let post = posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.cellId,
        for: indexPath) as! FeedCell
        cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        cell.headerLabel.text = post.title
        cell.subHeadLabel.text = "\(post.dateCreated?.toDisplayFormat() ?? "") • \(post.answers.count) Answers"
        cell.votingControls.upvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.votePost(postId: post.id, userId: self.currentUser!.id!, direction: voteDirection)
        }
        cell.votingControls.downvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.votePost(postId: post.id, userId: self.currentUser!.id!, direction: voteDirection)
        }
        
        //TODO: Add once profile picture edit is ready
//        if let picturePath = post.createdBy?.profilePicturePath {
//            // Set default image for placeholder
//            let placeholderImage = UIImage(systemName: "person.crop.circle")!
//
//            // Get a reference to the storage service using the default Firebase App
//            let storage = Storage.storage()
//
//            // Create a reference with an initial file path and name
//            let storagePathReference = storage.reference(withPath: picturePath)
//
//            // Load the image using SDWebImage
//            cell.thumbnailImageView.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
        //}
        
        if post.imagePath != nil {
            // Set default image for placeholder
            let placeholderImage = UIImage(named:"squatLogoPlaceholder")!
            
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            let pathname = K.Firestore.Storage.IMAGES_ROOT_DIR + "/" + (post.imagePath ?? "")
            
            // Create a reference with an initial file path and name
            let storagePathReference = storage.reference(withPath: pathname)
            
            // Load the image using SDWebImage
            cell.media.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
            
            cell.setConstraintsWithMedia()
        } else {
            cell.setConstraintsWithNoMedia()
        }
        cell.supportingTextLabel.text = post.description
        cell.postId = post.id
        cell.post = post
        cell.votingControls.votingUserId = currentUser?.id
        cell.votingControls.voteDirection = post.metrics.currentVoteDirection
        cell.votingControls.renderVotingControls()
        cell.cornerRadius = 0
        cell.overflowMenuTap = {
            let actionSheet = UIElementFactory.getActionSheet()
            let reportAction = MDCActionSheetAction(title: "Report", image: Images.flag, handler: { (MDCActionSheetHandler) in
                let reportViewController = ReportViewController.create(postId: post.id)
                self.present(reportViewController, animated: true)
            })
            actionSheet.addAction(reportAction)
            self.present(actionSheet, animated: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        viewPostHandler(exercisePost: post)
    }
    
    //Cache cell height to prevent jumpy recalc behavior
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            return
        }
        
        let h = cell.frame.size.height
        //print("@willDisplay [\(indexPath.item)] = \(h) height")
        cellHeights[indexPath] = h
    }

    //Query 'cache' for cell height to prevent jumpy recalc behavior
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
           sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let h = cellHeights[indexPath] ?? CGFloat(cellHeightEstimate)
        let w = UIScreen.main.bounds.size.width
        
        if indexPath.section == 1 {
            return CGSize(width:w, height: CGFloat(LoadingCell.CELL_HEIGHT))
        }
        
        
        let res = CGSize(width: w, height: h)
        //print("@sizeForItemAt [\(indexPath.item)] = \(h) height")
        return res
    }
    
    //handle infinite scrolling events
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !isFetchingMore && !endReached {
                print("================= =========== begin Batch Fetch!")
                isFetchingMore = true
                self.feedView.reloadSections(IndexSet(integer: 1))
                
                firstly {
                    self.fetchMorePosts(lastSnapshot: self.lastPostsSnapshot)
                }.done { newPosts in
                                        
                    self.endReached = newPosts.count == 0
                                   
                    self.posts += newPosts
                    self.feedView.reloadData()
                    print("postCount: \(self.posts.count)")
                    self.isFetchingMore = false
                }
            }
        }
    }

}

private extension FeedViewController {
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
              print("i=\(i)")
              indexFound = i
          }
          
          newPostsCopy.append(val)
      }
              
      
      if(diffType == .add) {
          newPostsCopy.insert(exercisePost, at: 0)
      }
      else if (diffType == .edit) { //using Notification center to get the updated post. DiffTool isn't detecting changes b/c Old Post is same as New Posts, as if it were strongly refenced/changed.
        print("indexFound: \(indexFound)")
        
        if(indexFound >= 0) {
            newPostsCopy[indexFound] = exercisePost
            feedView.performBatchUpdates({
                let idxPath = IndexPath(row: indexFound, section: 0)
                self.feedView.reloadItems(at: [idxPath])
            })
        }        
        
      } else if (diffType == .delete) {
          newPostsCopy.remove(at: indexFound)
      }

      diffedTableViewRenderer(argPosts: newPostsCopy)
    }

    @objc func updateTableViewEdittedPost(notif: Notification) {
        if let post = notif.userInfo?["post"] as? ExercisePost {
            diffedPostsHandler(diffType: .edit, exercisePost: post)
        }
    }
    
    func viewPostHandler(exercisePost: ExercisePost)  {
        let postDetailViewController = PostDetailViewController.create(postId: exercisePost.id, diffedPostsDataClosure: self.diffedPostsHandler  )
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
