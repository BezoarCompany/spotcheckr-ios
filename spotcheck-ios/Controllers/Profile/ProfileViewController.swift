import Foundation
import Firebase
import PromiseKit
import MaterialComponents
import FirebaseStorage.FIRStorageConstants
class ProfileViewController: UIViewController {
    @IBOutlet weak var certificationsHeadingLabel: UILabel!
    @IBOutlet weak var certificationsLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    var profilePictureImageView: UIImageView!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var answersTableView: UITableView!
    
    @objc func editProfileTapped(_ sender: Any) {
        let editProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.EditProfileViewControllerId)
        self.present(editProfileViewController, animated: true)
    }
    
    var tabBar: MDCTabBar?
    let tabBarView = UIView()
    let snackbarMessage: MDCSnackbarMessage = {
       let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
       return message
    }()
    var currentUser: User?
    var receivedUser: User?
    var answers = [Answer]()
    var posts = [ExercisePost]()
    let appBarViewController = UIElementFactory.getAppBar()
    let initialLoadActivityIndicator = UIElementFactory.getActivityIndicator()
    let postsTableActivityIndicator = UIElementFactory.getActivityIndicator()
    let answersTableActivityIndicator = UIElementFactory.getActivityIndicator()
    let postsRefreshControl = UIRefreshControl()
    let answersRefreshControl = UIRefreshControl()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAppBar()
        initTabBar()
        initTableViews()
        initProfileInfoControls()
        addSubviews()
        addObservers()
        resolveProfileUser()
        applyStyles()
        applyConstraints()
        hideFeatures()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileInformation), name: K.Notifications.ProfileEdited, object: nil)
    }
    
    func initProfileInfoControls() {
        profilePictureImageView = UIImageView()
        profilePictureImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func hideFeatures() {
        occupationLabel.isHidden = true
        certificationsLabel.isHidden = true
        certificationsHeadingLabel.isHidden = true
        heightLabel.isHidden = true
        weightLabel.isHidden = true
    }
    
    private func initAppBar() {
        self.appBarViewController.didMove(toParent: self)
        self.appBarViewController.navigationBar.rightBarButtonItem = UIBarButtonItem(image: Images.edit, style: .done, target: self, action: #selector(self.editProfileTapped(_:)))
    }
    
    private func addSubviews() {
        self.view.addSubview(appBarViewController.view)
        self.view.addSubview(self.tabBar!)
        //self.view.addSubview(profilePictureImageView)
    }
    
    private func resolveProfileUser() {
        self.initialLoadActivityIndicator.startAnimating()
        // Check if user received from another view controller (i.e. passed in from feed view).
        // https://www.youtube.com/watch?v=Kpwrc1PRDsg <- shows how to pass data from one view controller to this one.
        if self.receivedUser != nil {
            self.currentUser = self.receivedUser
            populateUserProfileInformation()
            //TODO: We will need to restrict the edit profile icon if you are viewing another person's profile.
        }
        else {
            firstly {
                //TODO: Show some sort of spinner while this data loads.
                Services.userService.getCurrentUser()
            }.done { user in
                self.currentUser = user
            }.catch { error in
                //TODO: Display error to the user that fetching the current user info failed.
            }.finally {
                //TODO: Dismiss spinner once data has loaded from user service and is populated.
                self.populateUserProfileInformation()
                firstly {
                    when(fulfilled: Services.exercisePostService.getPosts(forUser: self.currentUser!), Services.exercisePostService.getAnswers(byUserWithId: self.currentUser!.id!))
                }.done { posts, answers in
                    //TODO: Dismiss spinnner
                    //TODO: Add to table for posts and answers
                    self.tabBar?.items[0].title = "\(posts.count) Posts"
                    self.tabBar?.items[1].title = "\(answers.count) Answers"
                    self.answers = answers
                    self.posts = posts
                    
                    self.initialLoadActivityIndicator.stopAnimating()
                    self.postsTableView.reloadData()
                    self.answersTableView.reloadData()
                }.catch {error in
                    //TODO: Show error message on the table view for failing to fetch posts/answers
                }
            }
        }
    }
    
    private func populateUserProfileInformation() {
        //TODO: Resolve, what to do if we don't have their full name.
        self.appBarViewController.navigationBar.title = (self.currentUser?.information?.name.trim().isEmpty ?? true) ? "Anonymous" : self.currentUser?.information?.name
        if self.currentUser is Trainer {
            let trainer = self.currentUser as! Trainer
            if trainer.certifications.count == 0 {
                self.certificationsLabel.isHidden = true
                self.certificationsHeadingLabel.isHidden = true
            } else {
                for certification in trainer.certifications {
                    self.certificationsLabel.text?.append("\(certification.code), ")
                }
                self.certificationsLabel.text = self.certificationsLabel.text?.trimmingCharacters(in: CharacterSet.init(charactersIn: ", "))
            }
            self.occupationLabel.text = trainer.occupation
        }
        else {
            self.certificationsLabel.isHidden = true
            self.certificationsHeadingLabel.isHidden = true
            self.occupationLabel.isHidden = true
        }
        if self.currentUser?.measurement != nil {
            self.heightLabel.text = self.currentUser?.measurement?.height?.toFormattedHeight()
            self.weightLabel.text = self.currentUser?.measurement?.weight?.toFormattedWeight()
        }
        //TODO: Re-enable
//        if self.currentUser?.profilePicturePath != nil {
//            firstly {
//                Services.storageService.download(path: self.currentUser!.profilePicturePath!, maxSize: 2000000)
//            }.done { image in
//                self.profilePictureImageView.image = image
//            }.catch { (error) in
//                let errorCode = (error as NSError).code
//                var errorMessage = ""
//
//                switch errorCode {
//                case StorageErrorCode.downloadSizeExceeded.rawValue:
//                    errorMessage = "Profile picture is too large."
//                case StorageErrorCode.unknown.rawValue:
//                    errorMessage = "An unkown error occurred."
//                default:
//                    break
//                }
//                self.snackbarMessage.text = errorMessage
//                MDCSnackbarManager.show(self.snackbarMessage)
//            }
//        }
    }
    
    private func applyStyles() {
        certificationsLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        certificationsLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        certificationsHeadingLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        certificationsHeadingLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        occupationLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        occupationLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        heightLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        heightLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        weightLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        weightLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            self.postsTableActivityIndicator.centerXAnchor.constraint(equalTo: self.postsRefreshControl.centerXAnchor),
            self.postsTableActivityIndicator.centerYAnchor.constraint(equalTo: self.postsRefreshControl.centerYAnchor),
            self.initialLoadActivityIndicator.centerXAnchor.constraint(equalTo: self.postsTableView.centerXAnchor),
            self.initialLoadActivityIndicator.centerYAnchor.constraint(equalTo: self.postsTableView.centerYAnchor),
            self.answersTableActivityIndicator.centerXAnchor.constraint(equalTo: self.answersRefreshControl.centerXAnchor),
            self.answersTableActivityIndicator.centerYAnchor.constraint(equalTo: self.answersRefreshControl.centerYAnchor),
            (self.tabBar?.topAnchor.constraint(equalTo: self.appBarViewController.view.bottomAnchor))!,
            (self.tabBar?.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0))!,
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.tabBar!.trailingAnchor, constant: 0),
            self.answersTableView.topAnchor.constraint(equalTo: self.tabBar!.bottomAnchor, constant: 0),
            self.postsTableView.topAnchor.constraint(equalTo: self.tabBar!.bottomAnchor, constant: 0),
//            self.profilePictureImageView.topAnchor.constraint(equalTo: self.appBarViewController.navigationBar.bottomAnchor, constant: 16),
//            self.profilePictureImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            self.certificationsHeadingLabel.topAnchor.constraint(equalTo: self.appBarViewController.navigationBar.bottomAnchor, constant: 16)
        ])
    }
    
    @objc func updateProfileInformation() {
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            self.currentUser = user
            self.appBarViewController.navigationBar.title = "\(user.information?.name ?? "")"
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.postsTableView ? self.posts.count : self.answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.postsTableView {
            let post = posts[indexPath.row]
            let cell = self.postsTableView.dequeueReusableCell(withIdentifier: K.Storyboard.profilePostCellId, for: indexPath) as! ProfilePostCell
                
            cell.titleLabel.text = post.title
            cell.descriptionLabel.text = post.description
            cell.datePostedLabel.text = post.dateCreated?.toDisplayFormat()
            cell.votingUserId = self.currentUser?.id
            cell.postId = post.id
            cell.voteDirection = post.metrics.currentVoteDirection
            cell.answersCountLabel.text = "\(post.answersCount)"
            cell.upvoteOnTap = { (voteDirection: VoteDirection) in
                Services.exercisePostService.votePost(postId: post.id, userId: self.currentUser!.id!, direction: voteDirection)
            }
            cell.downvoteOnTap = { (voteDirection: VoteDirection) in
                Services.exercisePostService.votePost(postId: post.id, userId: self.currentUser!.id!, direction: voteDirection)
            }
            
            let moreIconActionSheet = UIElementFactory.getActionSheet()
            let deleteAction = MDCActionSheetAction(title: "Delete", image: Images.trash, handler: { (MDCActionSheetHandler) in
                firstly {
                    Services.exercisePostService.deletePost(post)
                }.done {
                    self.posts.remove(at: indexPath.row)
                    self.postsTableView.deleteRows(at: [indexPath], with: .right)
                    self.tabBar?.items[0].title = "\(self.posts.count) Posts"
                    self.snackbarMessage.text = "Post deleted."
                    MDCSnackbarManager.show(self.snackbarMessage)
                }
                .catch { error in
                    self.snackbarMessage.text = "Failed to delete post."
                    MDCSnackbarManager.show(self.snackbarMessage)
                }
            })
            moreIconActionSheet.addAction(deleteAction)
            cell.onMoreIconClick = {
                self.present(moreIconActionSheet, animated: true, completion: nil)
            }
            return cell
        }
        
        let answer = answers[indexPath.row]
        let cell = self.answersTableView.dequeueReusableCell(withIdentifier: K.Storyboard.profilePostCellId, for: indexPath) as! ProfilePostCell
            
        cell.descriptionLabel.text = answer.text
        cell.datePostedLabel.text = answer.dateCreated?.toDisplayFormat()
        cell.votingUserId = self.currentUser?.id
        cell.voteDirection = answer.metrics?.currentVoteDirection
        cell.hideAnswers = true
        cell.upvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteAnswer(answerId: answer.id!, userId: self.currentUser!.id!, direction: voteDirection)
        }
        cell.downvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteAnswer(answerId: answer.id!, userId: self.currentUser!.id!, direction: voteDirection)
        }
        
        let moreIconActionSheet = UIElementFactory.getActionSheet()
        let deleteAction = MDCActionSheetAction(title: "Delete", image: Images.trash, handler: { (MDCActionSheetHandler) in
            firstly {
                Services.exercisePostService.deleteAnswer(answer)
            }.done {
                self.answers.remove(at: indexPath.row)
                self.answersTableView.deleteRows(at: [indexPath], with: .right)
                self.tabBar?.items[1].title = "\(self.answers.count) Answers"
                self.snackbarMessage.text = "Answer deleted."
                MDCSnackbarManager.show(self.snackbarMessage)
            }
            .catch { error in
                self.snackbarMessage.text = "Failed to delete answer."
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        })
        moreIconActionSheet.addAction(deleteAction)
        cell.onMoreIconClick = {
            self.present(moreIconActionSheet, animated: true, completion: nil)
        }
        cell.awakeFromNib()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! ProfilePostCell
        cell.adjustVotingControls()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postDetailViewController: PostDetailViewController
        if tableView == self.postsTableView {
            postDetailViewController = PostDetailViewController.create(postId: posts[indexPath.row].id)
        }
        else {
            postDetailViewController = PostDetailViewController.create(postId: answers[indexPath.row].exercisePostId)
        }
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
    
    private func initTableViews() {
        //TODO: Refreshing like this will mean a hit for fetching all the documents over again.
        //We really only want the diff of documents based on the last refresh date so that we're pulling less data.
        self.postsRefreshControl.addSubview(self.postsTableActivityIndicator)
        self.postsRefreshControl.tintColor = .clear
        self.postsRefreshControl.backgroundColor = .clear
        self.postsRefreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        self.postsTableView.addSubview(self.postsRefreshControl)
        self.postsTableView.tableFooterView = UIView()
        self.postsTableView.register(UINib(nibName:K.Storyboard.profilPostNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.profilePostCellId)
        self.postsTableView.addSubview(self.initialLoadActivityIndicator)
        
        self.answersRefreshControl.addSubview(self.answersTableActivityIndicator)
        self.answersRefreshControl.tintColor = .clear
        self.answersRefreshControl.backgroundColor = .clear
        self.answersRefreshControl.addTarget(self, action: #selector(refreshAnswers), for: .valueChanged)
        self.answersTableView.addSubview(self.answersRefreshControl)
        self.answersTableView.tableFooterView = UIView()
        self.answersTableView.register(UINib(nibName:K.Storyboard.profilPostNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.profilePostCellId)
    }
    
    @objc func refreshPosts() {
        self.postsTableActivityIndicator.startAnimating()
        firstly {
            Services.exercisePostService.getPosts(forUser: self.currentUser!)
        }.done { posts in
            self.posts = posts
            self.tabBar?.items[0].title = "\(self.posts.count) Posts"
            self.postsTableView.reloadData()
        }.catch{ (error) in
            self.snackbarMessage.text = "Error refreshing posts"
            MDCSnackbarManager.show(self.snackbarMessage)
        }.finally {
            self.perform(#selector(self.finishRefreshing), with: nil, afterDelay: 0.1)
        }
    }
    
    @objc func refreshAnswers() {
        self.answersTableActivityIndicator.startAnimating()
        firstly {
            Services.exercisePostService.getAnswers(byUserWithId: (self.currentUser?.id!)!)
        }.done { answers in
            self.answers = answers
            self.tabBar?.items[1].title = "\(self.answers.count) Answers"
            self.answersTableView.reloadData()
        }.catch{ (error) in
            self.snackbarMessage.text = "Error refreshing answers"
            MDCSnackbarManager.show(self.snackbarMessage)
        }.finally {
            self.perform(#selector(self.finishRefreshing), with: nil, afterDelay: 0.1)
        }
    }
    
    @objc func finishRefreshing() {
        self.postsTableActivityIndicator.stopAnimating()
        self.answersTableActivityIndicator.stopAnimating()
        self.postsRefreshControl.endRefreshing()
        self.answersRefreshControl.endRefreshing()
    }
}

extension ProfileViewController: MDCTabBarDelegate {
    private func initTabBar() {
        self.tabBar = MDCTabBar(frame: self.view.bounds)
        self.tabBar?.delegate = self
        self.tabBar?.translatesAutoresizingMaskIntoConstraints = false
        self.tabBar?.items = [
            UITabBarItem(title: "\(posts.count) Posts", image: nil, tag: 0),
            UITabBarItem(title: "\(answers.count) Answers", image: nil, tag: 1)
        ]
        self.tabBar?.itemAppearance = .titles
        self.tabBar?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.tabBar?.sizeToFit()
        self.tabBar?.applyPrimaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .any
    }
    
    func tabBar(_ tabBar: MDCTabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            tabBar.selectedItem = tabBar.items[0]
            self.postsTableView.isHidden = false
            self.answersTableView.isHidden = true
        case 1:
            tabBar.selectedItem = tabBar.items[1]
            self.answersTableView.isHidden = false
            self.postsTableView.isHidden = true
        default:
            break
        }
    }
}
