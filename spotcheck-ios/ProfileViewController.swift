import Foundation
import Firebase
import PromiseKit
import MaterialComponents

class ProfileViewController: UIViewController {
    @IBOutlet weak var certificationsHeadingLabel: UILabel!
    @IBOutlet weak var certificationsLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var editProfileButton: MDCFlatButton!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var answersTableView: UITableView!
    
    @objc func logoutTapped(_ sender: Any) {
        do {
            try Services.userService.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let baseViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId )
            UIApplication.shared.keyWindow?.rootViewController = baseViewController
        } catch {
            self.snackbarMessage.text = "An error occurred signing out."
            MDCSnackbarManager.show(self.snackbarMessage)
        }
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
        addSubviews()
        resolveProfileUser()
        applyStyles()
        applyConstraints()
    }
    
    private func initAppBar() {
        self.appBarViewController.didMove(toParent: self)
        self.appBarViewController.navigationBar.rightBarButtonItem = UIBarButtonItem(image: Images.logOut, style: .done, target: self, action: #selector(self.logoutTapped(_:)))
    }
    
    private func addSubviews() {
        self.view.addSubview(appBarViewController.view)
        self.view.addSubview(self.tabBar!)
    }
    
    private func resolveProfileUser() {
        // Check if user received from another view controller (i.e. passed in from feed view).
        // https://www.youtube.com/watch?v=Kpwrc1PRDsg <- shows how to pass data from one view controller to this one.
        if self.receivedUser != nil {
            self.currentUser = self.receivedUser
            populateUserProfileInformation()
        }
        else {
            showCurrentUserOnlyControls()
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
                    //TODO: Show spinner that table data is loading.
                    when(fulfilled: Services.exercisePostService.getPosts(forUser: self.currentUser!), Services.exercisePostService.getAnswers(byUserWithId: self.currentUser!.id!))
                }.done { posts, answers in
                    //TODO: Dismiss spinnner
                    //TODO: Add to table for posts and answers
                    self.tabBar?.items[0].title = "\(posts.count) Posts"
                    self.tabBar?.items[1].title = "\(answers.count) Answers"
                    self.answers = answers
                    self.posts = posts
                    
                    self.postsTableView.reloadData()
                    self.answersTableView.reloadData()
                }.catch {error in
                    //TODO: Show error message on the table view for failing to fetch posts/answers
                }
            }
        }
    }
    
    private func showCurrentUserOnlyControls() {
        self.editProfileButton.isHidden = false
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
            self.heightLabel.isHidden = false
            self.weightLabel.isHidden = false
            self.heightLabel.text = self.currentUser?.measurement?.height?.toFormattedHeight()
            self.weightLabel.text = self.currentUser?.measurement?.weight?.toFormattedWeight()
        }
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
        self.postsTableActivityIndicator.centerXAnchor.constraint(equalTo: self.postsRefreshControl.centerXAnchor).isActive = true
        self.postsTableActivityIndicator.centerYAnchor.constraint(equalTo: self.postsRefreshControl.centerYAnchor).isActive = true
        self.answersTableActivityIndicator.centerXAnchor.constraint(equalTo: self.answersRefreshControl.centerXAnchor).isActive = true
        self.answersTableActivityIndicator.centerYAnchor.constraint(equalTo: self.answersRefreshControl.centerYAnchor).isActive = true
        self.tabBar?.translatesAutoresizingMaskIntoConstraints = false
        self.tabBar?.topAnchor.constraint(equalTo: self.weightLabel.bottomAnchor, constant: 10).isActive = true
        self.tabBar?.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.tabBar!.trailingAnchor, constant: 0).isActive = true
        self.answersTableView.topAnchor.constraint(equalTo: self.tabBar!.bottomAnchor, constant: 0).isActive = true
        self.postsTableView.topAnchor.constraint(equalTo: self.tabBar!.bottomAnchor, constant: 0).isActive = true
        self.profilePictureImageView.topAnchor.constraint(equalTo: self.appBarViewController.navigationBar.bottomAnchor, constant: 16).isActive = true
        self.certificationsHeadingLabel.topAnchor.constraint(equalTo: self.appBarViewController.navigationBar.bottomAnchor, constant: 16).isActive = true
        self.editProfileButton.topAnchor.constraint(equalTo: self.appBarViewController.navigationBar.bottomAnchor, constant: 16).isActive = true
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
            cell.answersCountLabel.text = "\(post.answers.count)"
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
                Services.exercisePostService.deleteAnswer(withId: answer.id!)
            }.done {
                self.answers.remove(at: indexPath.row)
                self.answersTableView.deleteRows(at: [indexPath], with: .right)
                self.tabBar?.items[1].title = "\(self.answers.count) Answers"
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
        if tableView == self.postsTableView {
            let postDetailViewController = PostDetailViewController.create(post: posts[indexPath.row])
            self.navigationController?.pushViewController(postDetailViewController, animated: true)
        }
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
