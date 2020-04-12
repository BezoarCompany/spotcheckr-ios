import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit
import MaterialComponents

class PostDetailViewController : UIViewController {
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
    }()
    let cellHeightEstimate = 185.0
    let cellEstimatedSize: CGSize = {
        let w = UIScreen.main.bounds.size.width
        let h = CGFloat(185)
        let size = CGSize(width: w, height: h)
        return size
    }()
    
    @objc func addAnswerButton(_ sender: Any) {
        let createAnswerViewController = CreateAnswerViewController.create(post: post)
        createAnswerViewController.createAnswerClosure = appendAnswerToPost
        self.present(createAnswerViewController, animated: true)
    }

    typealias DiffedPostsDataUpdateClosureType = ((_ diffType: DiffType, _ post: ExercisePost) -> Void) //takes diff type, and post to be modified
    
    var diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? //To dynamically update FeedView's cell with the new/updated post
    
    var post: ExercisePost?
    var postId: String?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let appBarViewController = UIElementFactory.getAppBar()
    let answerReplyButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Images.reply, for: .normal)
        return button
    }()
    var currentUser: User?
    var answers = [Answer]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    
    func updatePostDetail(argPost: ExercisePost) {
        self.post = argPost
        let idxPath = IndexPath(row: 0, section: 0)
        
//        self.tableView.beginUpdates()
//        self.tableView.reloadRows(at: [idxPath], with: .automatic)
//        self.tableView.endUpdates()
    }
    
    static func create(postId: String?, diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? = nil) -> PostDetailViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let postDetailViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.PostDetailViewControllerId) as! PostDetailViewController
        
        postDetailViewController.postId = postId
        postDetailViewController.diffedPostsDataClosure = diffedPostsDataClosure
        
        return postDetailViewController
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(appBarViewController.view)
        appBarViewController.didMove(toParent: self)
        
        initCollectionView()
        initActivityIndicator()
        initReplyButton()
        applyConstraints()
        
        firstly {
            when(fulfilled: Services.exercisePostService.getPost(withId: postId!), Services.userService.getCurrentUser())
        }.done { post, user in
            self.post = post
            self.appBarViewController.navigationBar.title = "\(self.post?.answersCount ?? 0) Answers"
            self.appBarViewController.navigationBar.leadingBarButtonItem = UIBarButtonItem(image: Images.back, style: .done, target: self, action: #selector(self.backOnClick(sender:)))
            self.currentUser = user
            if let postUserId = self.post?.createdBy?.id, postUserId == user.id {
                self.appBarViewController.navigationBar.trailingBarButtonItem = UIBarButtonItem(image: Images.moreVertical, style: .plain, target: self, action: #selector(self.modifyPost))
            }
            self.collectionView.reloadData()
        }
    }
    
    @objc func backOnClick(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func modifyPost () {
        let userActionSheet = UIElementFactory.getActionSheet()
        userActionSheet.title = "Choose Action"
        
        let editAction = MDCActionSheetAction(title: "Edit", image: Images.edit, handler: { (MDCActionSheetAction) in
            let createPostViewController = CreatePostViewController.create(updatePostMode: .edit, post: self.post, diffedPostsDataClosure: self.diffedPostsDataClosure,
                                                                           updatePostDetailClosure: self.updatePostDetail )
            
            //TODO: Update PostDetail after edit, as well as in Feed TableView
            self.present(createPostViewController, animated: true)
        })
        
        let deleteAction = MDCActionSheetAction(title: "Delete", image: Images.trash) { (MDCActionSheetAction) in
            let deleteAlertController = MDCAlertController(title: "Are you sure you want to delete this post?", message: "This will delete all included answers too.")
            
            let deleteAlertAction = MDCAlertAction(title: "Delete", emphasis: .high, handler: { (MDCAlertAction) in
                self.activityIndicator.startAnimating()
                
                firstly {
                    Services.exercisePostService.deletePost(self.post!)
                }.done {
                    self.activityIndicator.stopAnimating()
                    
                    if let updateTableView = self.diffedPostsDataClosure {
                        updateTableView(.delete, self.post!)
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }.catch { err in
                    self.activityIndicator.stopAnimating()

                    let postId = self.post?.id ?? ""
                    print(err)
                    let msg = "ERROR deleting post \(postId)"
                    
                    let snackbarMessage = MDCSnackbarMessage()
                    snackbarMessage.text = msg
                    print(msg)
                    self.navigationController?.popViewController(animated: true)
                    MDCSnackbarManager.show(snackbarMessage)

                }
            })
            
            deleteAlertController.addAction(deleteAlertAction)
            deleteAlertController.addAction(MDCAlertAction(title: "Cancel", emphasis:.high, handler: nil))
            deleteAlertController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
            
            self.present(deleteAlertController, animated: true, completion: nil)
        }
        
        userActionSheet.addAction(editAction)
        userActionSheet.addAction(deleteAction)
        
        self.present(userActionSheet, animated: true, completion: nil)
    
    }
}

extension PostDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    enum CollectionViewSections: Int {
        case PostInformation, Answers
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case CollectionViewSections.PostInformation.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Storyboard.feedCellId,
            for: indexPath) as! FeedCell
            cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
            cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
            cell.isInteractable = false
            cell.headerLabel.text = post?.title
            cell.headerLabel.numberOfLines = 0
            cell.subHeadLabel.text = "\(post?.dateCreated?.toDisplayFormat() ?? "")"
            cell.votingControls.upvoteOnTap = { (voteDirection: VoteDirection) in
                Services.exercisePostService.votePost(postId: self.post!.id, userId: (self.currentUser?.id!)!, direction: voteDirection)
            }
            cell.votingControls.downvoteOnTap = { (voteDirection: VoteDirection) in
                Services.exercisePostService.votePost(postId: self.post!.id, userId: (self.currentUser?.id!)!, direction: voteDirection)
            }
    
            if post?.imagePath != nil {
                // Set default image for placeholder
                let placeholderImage = UIImage(named:"squatLogoPlaceholder")!
                
                // Get a reference to the storage service using the default Firebase App
                let storage = Storage.storage()
                let pathname = K.Firestore.Storage.IMAGES_ROOT_DIR + "/" + (post?.imagePath ?? "")
                
                // Create a reference with an initial file path and name
                let storagePathReference = storage.reference(withPath: pathname)
                
                // Load the image using SDWebImage
                cell.media.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
                
                cell.setConstraintsWithMedia()
            } else {
                cell.setConstraintsWithNoMedia()
            }
            cell.supportingTextLabel.text = post?.description
            cell.supportingTextLabel.numberOfLines = 0
            cell.postId = post?.id
            cell.post = post
            cell.votingControls.votingUserId = currentUser?.id
            cell.votingControls.voteDirection = post?.metrics.currentVoteDirection
            cell.votingControls.renderVotingControls()
            cell.cornerRadius = 0
            cell.overflowMenuTap = {
                let actionSheet = UIElementFactory.getActionSheet()
                let reportAction = MDCActionSheetAction(title: "Report", image: Images.flag, handler: { (MDCActionSheetHandler) in
                    let reportViewController = ReportViewController.create(postId: self.post?.id)
                    self.present(reportViewController, animated: true)
                })
                actionSheet.addAction(reportAction)
                self.present(actionSheet, animated: true)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func initCollectionView() {
        view.addSubview(collectionView)
        layout.estimatedItemSize = cellEstimatedSize
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: K.Storyboard.feedCellId)
        collectionView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
    }
}
extension PostDetailViewController {
    func initActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        collectionView.addSubview(activityIndicator)
    }
    
    func initReplyButton() {
        answerReplyButton.addTarget(self, action: #selector(addAnswerButton(_:)), for: .touchUpInside)
        collectionView.addSubview(answerReplyButton)
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -55),
            answerReplyButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor , constant: -20),
            answerReplyButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -75),
            answerReplyButton.widthAnchor.constraint(equalToConstant: 64),
            answerReplyButton.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
    
    func appendAnswerToPost(ans: Answer) {
        //ost?.answers.append(ans)
        //tableView.reloadSections(IndexSet(integer: 1), with: UITableView.RowAnimation.none)//re-render only answers section
    }
}
