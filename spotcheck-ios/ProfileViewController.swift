import Foundation
import Firebase
import PromiseKit
import MaterialComponents.MDCFlatButton

class ProfileViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var certificationsHeadingLabel: UILabel!
    @IBOutlet weak var certificationsLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var postsButton: MDCFlatButton!
    @IBOutlet weak var answersButton: MDCFlatButton!
    @IBOutlet weak var editProfileButton: MDCFlatButton!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var answersTableView: UITableView!
    
    @IBAction func postsButtonOnClick(_ sender: Any) {
        self.postsTableView.isHidden = false
        self.answersTableView.isHidden = true
        self.postsButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        self.postsButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        self.answersButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.primaryColor)
        self.answersButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor, for: .normal)
    }
    
    @IBAction func answersButtonOnClick(_ sender: Any) {
        self.answersTableView.isHidden = false
        self.postsTableView.isHidden = true
        self.answersButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        self.answersButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        self.postsButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.primaryColor)
        self.postsButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor, for: .normal)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
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
    
    let snackbarMessage: MDCSnackbarMessage = {
       let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
       return message
    }()
    
    var currentUser: User?
    var receivedUser: User?
    
    var answers = [Answer]()
    var posts = [ExercisePost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableViews()
        resolveProfileUser()
        applyStyles()
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
                    self.postsButton.setTitle("\(posts.count) Posts", for: .normal)
                    self.answersButton.setTitle("\(answers.count) Answers", for: .normal)
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
        self.nameLabel.text = (self.currentUser?.information?.fullName.isEmpty ?? true) ? "Anonymous" : self.currentUser?.information?.fullName
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
        nameLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        nameLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
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
        
        postsButton.applyOutlinedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        postsButton.setTitleFont(ApplicationScheme.instance.containerScheme.typographyScheme.button, for: .normal)
        postsButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        postsButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        answersButton.applyOutlinedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        answersButton.setTitleFont(ApplicationScheme.instance.containerScheme.typographyScheme.button, for: .normal)
        answersButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor, for: .normal)
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
            cell.voteTotalLabel.text = "\(post.metrics.totalVotes)"
            cell.votingUserId = self.currentUser?.id
            cell.postId = post.id
            cell.voteDirection = post.metrics.currentVoteDirection
            cell.answersCountLabel.text = "\(post.answers.count)"
            let moreIconActionSheet = UIElementFactory.getActionSheet()
            let deleteAction = MDCActionSheetAction(title: "Delete", image: Images.trash, handler: { (MDCActionSheetHandler) in
                firstly {
                    Services.exercisePostService.deletePost(post)
                }.done {
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
        cell.voteTotalLabel.text = "\(answer.metrics!.totalVotes)"
        cell.votingUserId = self.currentUser?.id
        cell.voteDirection = answer.metrics?.currentVoteDirection
        cell.hideAnswers = true
        let moreIconActionSheet = UIElementFactory.getActionSheet()
        let deleteAction = MDCActionSheetAction(title: "Delete", image: Images.trash, handler: { (MDCActionSheetHandler) in
            firstly {
                Services.exercisePostService.deleteAnswer(withId: answer.id!)
            }.done {
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
        self.postsTableView.tableFooterView = UIView()
        self.postsTableView.register(UINib(nibName:K.Storyboard.profilPostNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.profilePostCellId)
        self.answersTableView.tableFooterView = UIView()
        self.answersTableView.register(UINib(nibName:K.Storyboard.profilPostNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.profilePostCellId)
    }
}
