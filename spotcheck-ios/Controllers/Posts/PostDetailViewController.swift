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
    var postId: ExercisePostID?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let appBarViewController = UIElementFactory.getAppBar()
    let answerReplyButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Images.reply, for: .normal)
        return button
    }()
    let snackbarMessage: MDCSnackbarMessage = {
       let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
       return message
    }()
    let defaultAnswersSectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.text = "There are no answers, be the first to help!"
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        return label
    }()
    var postYAxisAnchor: NSLayoutYAxisAnchor!
    var postCellHeight: CGFloat!
    
    var currentUser: User?
    var answers = [Answer]()
    var answersCount = 0
    
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
    
    static func create(postId: ExercisePostID?, diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? = nil) -> PostDetailViewController {
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
        initAnswersSection()
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
            self.collectionView.reloadData()
        }.catch { error in
            self.dismiss(animated: true) {
                self.snackbarMessage.text = "There was an error loading the post."
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.finally {
            firstly {
                Services.exercisePostService.getAnswers(forPostWithId: self.post!.id!)
            }.done { answers in
                self.answers = answers
                self.answersCount = self.answers.count
                self.collectionView.reloadData()
            }.catch { (error) in
                self.snackbarMessage.text = "There was an error loading answers."
                MDCSnackbarManager.show(self.snackbarMessage)
            }.finally {
                if self.answersCount == 0 {
                    let h = (self.collectionView.frame.height - self.postCellHeight) / 2
                    self.defaultAnswersSectionLabel.topAnchor.constraint(equalTo: self.postYAxisAnchor, constant: h).isActive = true
                    self.defaultAnswersSectionLabel.isHidden = false
                }
            }
        }
    }
    
    @objc func backOnClick(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PostDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    enum CollectionViewSections: Int {
        case PostInformation, Answers
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case CollectionViewSections.PostInformation.rawValue:
            return 1
        case CollectionViewSections.Answers.rawValue:
            return answers.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == CollectionViewSections.PostInformation.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Storyboard.feedCellId,
            for: indexPath) as! FeedCell
            cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
            cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
            cell.isInteractable = false
            cell.headerLabel.text = post?.title
            cell.headerLabel.numberOfLines = 0
            cell.subHeadLabel.text = "\(post?.dateCreated?.toDisplayFormat() ?? "")"
            cell.votingControls.upvoteOnTap = { (voteDirection: VoteDirection) in
                Services.exercisePostService.voteContent(contentId: self.post!.id!, userId: (self.currentUser?.id!)!, direction: voteDirection)
            }
            cell.votingControls.downvoteOnTap = { (voteDirection: VoteDirection) in
                Services.exercisePostService.voteContent(contentId: self.post!.id!, userId: (self.currentUser?.id!)!, direction: voteDirection)
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
                postCellHeight = cell.frame.height + CGFloat(FeedCell.IMAGE_HEIGHT)
            } else {
                cell.setConstraintsWithNoMedia()
                postCellHeight = cell.frame.height
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
                    let reportViewController = ReportViewController.create(contentId: self.post?.id)
                    self.present(reportViewController, animated: true)
                })
                
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

                            let postId = self.post?.id ?? nil
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
                
                if self.currentUser?.id == self.post?.createdBy?.id {
                    actionSheet.addAction(editAction)
                    actionSheet.addAction(deleteAction)
                }
                actionSheet.addAction(reportAction)
               
                self.present(actionSheet, animated: true)
            }
            cell.setOverflowMenuLocation(location: .top)
            cell.setFullBleedDivider()
            postYAxisAnchor = cell.bottomAnchor
            
            return cell
        }
        
        let answer = answers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Storyboard.answerCellId,
                                                      for: indexPath) as! AnswerCell
        let isLastCell = { (indexPath: IndexPath) in return indexPath.row == self.answersCount - 1 }
        if isLastCell(indexPath) {
            cell.hideDivider()
        }
        cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        cell.isInteractable = false
        cell.headerLabel.text = answer.createdBy?.information?.name
        cell.headerLabel.numberOfLines = 0
        cell.subHeadLabel.text = "\(answer.dateCreated?.toDisplayFormat() ?? "")"
        cell.votingControls.upvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteContent(contentId: answer.id!, userId: (self.currentUser?.id!)!, direction: voteDirection)
        }
        cell.votingControls.downvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteContent(contentId: answer.id!, userId: (self.currentUser?.id!)!, direction: voteDirection)
        }
        cell.supportingTextLabel.text = answer.text
        cell.supportingTextLabel.numberOfLines = 0
        cell.votingControls.votingUserId = currentUser?.id
        //cell.votingControls.voteDirection = answer.metrics?.currentVoteDirection
        cell.votingControls.renderVotingControls()
        cell.cornerRadius = 0
        cell.overflowMenuTap = {
            let actionSheet = UIElementFactory.getActionSheet()
            let reportAction = MDCActionSheetAction(title: "Report", image: Images.flag, handler: { (MDCActionSheetHandler) in
                let reportViewController = ReportViewController.create(contentId: answer.id)
                self.present(reportViewController, animated: true)
            })
            
            if answer.createdBy?.id == self.currentUser?.id {
                let deleteCommentAction = MDCActionSheetAction(title: "Delete", image: Images.trash) { (MDCActionSheetAction) in
                    let deleteCommentAlertController = MDCAlertController(title: nil, message: "Are you sure you want to delete your comment?")
                
                let deleteCommentAlertAction = MDCAlertAction(title: "Delete", emphasis: .high, handler: { (MDCAlertAction) in
                        //TODO: Show activity indicator
                        firstly {
                            Services.exercisePostService.deleteAnswer(answer)
                        }.done {
                            //TODO: Stop animating activity indicator
                            self.answersCount -= 1
                            self.appBarViewController.navigationBar.title = "\(self.answersCount) Answers"
                            collectionView.deleteItems(at: [indexPath])
                        }.catch { err in
                            self.snackbarMessage.text = "Unable to delete answer."
                            MDCSnackbarManager.show(self.snackbarMessage)
                        }
                    })
                    
                deleteCommentAlertController.addAction(deleteCommentAlertAction)
                deleteCommentAlertController.addAction(MDCAlertAction(title: "Cancel", emphasis:.high, handler: nil))
                deleteCommentAlertController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
                self.present(deleteCommentAlertController, animated: true)
                }
                actionSheet.addAction(deleteCommentAction);
            }
            
            actionSheet.addAction(reportAction)
            self.present(actionSheet, animated: true)
        }
        cell.setOverflowMenuLocation(location: .top)
        
        print("answers rendered")
        return cell
    }
    
    func initCollectionView() {
        view.addSubview(collectionView)
        layout.estimatedItemSize = cellEstimatedSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: K.Storyboard.feedCellId)
        collectionView.register(AnswerCell.self, forCellWithReuseIdentifier: K.Storyboard.answerCellId)
        collectionView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
    }
    
    func initAnswersSection() {
        collectionView.addSubview(defaultAnswersSectionLabel)
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
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -55),
            answerReplyButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor , constant: -20),
            answerReplyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75),
            answerReplyButton.widthAnchor.constraint(equalToConstant: 64),
            answerReplyButton.heightAnchor.constraint(equalToConstant: 64),
            defaultAnswersSectionLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
        ])
    }
    
    func appendAnswerToPost(ans: Answer) {
        //ost?.answers.append(ans)
        //tableView.reloadSections(IndexSet(integer: 1), with: UITableView.RowAnimation.none)//re-render only answers section
    }
}
