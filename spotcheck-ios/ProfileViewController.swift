import Foundation
import Firebase
import PromiseKit
import MaterialComponents.MDCFlatButton

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
    
    let userService = UserService()
    let exercisePostService = ExercisePostService()
    
    var currentUser: User?
    var receivedUser: User?
    
    var answers = [Answer]()
    var posts = [ExercisePost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postsTableView.register(UINib(nibName:K.Storyboard.profilPostNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.profilePostCellId)
        //TODO: Remove, only for testing purposes
        //setupTestUser()
        resolveProfileUser()
        applyStyles()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        print("votedirection is \(cell.voteDirection!.get())")
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! ProfilePostCell
        cell.adjustVotingControls()
    }
    
    private func setupTestUser() {
        self.currentUser = FakeDataFactory.GetTrainers(count: 1)[0]
        populateUserProfileInformation()
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
                self.userService.getCurrentUser()
            }.done { user in
                self.currentUser = user
            }.catch { error in
                //TODO: Display error to the user that fetching the current user info failed.
            }.finally {
                //TODO: Dismiss spinner once data has loaded from user service and is populated.
                self.populateUserProfileInformation()
                firstly {
                    //TODO: Show spinner that table data is loading.
                    when(fulfilled: self.exercisePostService.getPosts(forUserWithId: self.currentUser!.id!), self.exercisePostService.getAnswers(byUserWithId: self.currentUser!.id!))
                }.done { posts, answers in
                    //TODO: Dismiss spinnner
                    //TODO: Add to table for posts and answers
                    self.postsButton.setTitle("\(posts.count) Posts", for: .normal)
                    self.answersButton.setTitle("\(answers.count) Answers", for: .normal)
                    self.answers = answers
                    self.posts = posts
                    
                    self.postsTableView.reloadData()
                    print(posts)
                    print(answers)
                }.catch {error in
                    //TODO: Show error message on the table view for failing to fetch posts/answers
                }
            }
        }
    }
    
    @IBAction func postsButtonOnClick(_ sender: Any) {
        self.postsTableView.isHidden = false
        //self.answersTableView.isHidden = true
    }
    
    @IBAction func answersButtonOnClick(_ sender: Any) {
        //self.answersTableView.isHidden = false
        self.postsTableView.isHidden = true
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
        
        postsButton.setTitleFont(ApplicationScheme.instance.containerScheme.typographyScheme.button, for: .normal)
        postsButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor, for: .normal)
        answersButton.setTitleFont(ApplicationScheme.instance.containerScheme.typographyScheme.button, for: .normal)
        answersButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor, for: .normal)
    
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId )
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
}
