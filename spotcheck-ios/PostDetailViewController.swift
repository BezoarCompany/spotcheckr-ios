import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit
import MaterialComponents

class PostDetailViewController : UIViewController {
    
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postAuthorLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var numAnswersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addAnswerButton(_ sender: Any) {
        let createAnswerViewController = CreateAnswerViewController.create(post: post)
        self.present(createAnswerViewController, animated: true)
    }
    
    var post: ExercisePost?
    let exercisePostService = ExercisePostService()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let appBarViewController = UIElementFactory.getAppBar()
    let answerReplyButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Images.reply, for: .normal)
        return button
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    typealias DiffedPostsDataUpdateClosureType = ((_ diffType: DiffType, _ post: ExercisePost) -> Void) //takes diff type, and post to be modified
    var diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? //To dynamically update UITableView with the new post
    
    func updatePostDetail(argPost: ExercisePost) {
        self.post = argPost
        print("PostDetail.updatePostDetail() \(argPost.title)")
        let idxPath = IndexPath(row: 0, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [idxPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    static func create(postId: String?, diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? = nil) -> PostDetailViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)

        let postDetailViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.PostDetailViewControllerId) as! PostDetailViewController
        
        firstly {
            Services.exercisePostService.getPost(withId: postId!)
        }.done { post in
            postDetailViewController.post = post
        }
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
        
        firstly {
            //TODO: Replace with call to getAnswers(from: Number) which returns all answers since a specific "page length" (e.g. get first 10 posts by created date, scroll, when reached 8/10 posts fetch next 10 posts.
            self.exercisePostService.getAnswers(forPostWithId : post?.id ?? "" )
        }.done { answers in
            self.post?.answers = answers
            self.post?.answersCount = answers.count
            self.appBarViewController.navigationBar.title = "\(answers.count) Answers"
            self.appBarViewController.navigationBar.leadingBarButtonItem = UIBarButtonItem(image: Images.back, style: .done, target: self, action: #selector(self.backOnClick(sender:)))
            self.tableView.reloadData()
        }.catch { error in
            //TODO: Do something when post fetching fails
        }
        
        //access control for the modify menu
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            if let postUserId = self.post?.createdBy?.id, postUserId == user.id{
                self.appBarViewController.navigationBar.trailingBarButtonItem = UIBarButtonItem(image: Images.edit, style: .plain, target: self, action: #selector(self.modifyPost))
            }
        }
                
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName:K.Storyboard.detailedPostNibName , bundle: nil), forCellReuseIdentifier: K.Storyboard.detailedPostCellId)
        tableView.register(UINib(nibName:K.Storyboard.answerNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.answerCellId)
        tableView.addSubview(answerReplyButton)
        tableView.separatorInset = UIEdgeInsets(top: -10,left: 0,bottom: 0,right: 0)
        
        initActivityIndicator()
        initReplyButton()
        applyConstraints()
    }
    
    @objc func backOnClick(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func modifyPost () {
        let alert = UIAlertController(title: "Choose Action", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit ", style: .default, handler: { _ in
            let createPostViewController = CreatePostViewController.create(updatePostMode: .edit, post: self.post, diffedPostsDataClosure: self.diffedPostsDataClosure,
                                                                           updatePostDetailClosure: self.updatePostDetail )
            
            //TODO: Update PostDetail after edit, as well as in Feed TableView
            self.present(createPostViewController, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
            let deleteOption = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                
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
                    print("ERROR deleting post(\(self.post?.id))")
                    
                }
            })
            deleteOption.setValue(UIColor.systemRed, forKey: "titleTextColor")
            
            let deleteAlert = UIAlertController(title: "Are you sure you want to delete this post?", message: "This will delete all included answers too", preferredStyle: UIAlertController.Style.alert)
            deleteAlert.addAction(deleteOption)

            deleteAlert.addAction(UIAlertAction(title: "Cancel",style: .cancel, handler: { (action: UIAlertAction!) in

            }))
            self.present(deleteAlert, animated: true, completion: nil)
            
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    
    }
    
    func initActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.view.addSubview(activityIndicator)
    }
    
    func initReplyButton() {
        answerReplyButton.addTarget(self, action: #selector(addAnswerButton(_:)), for: .touchUpInside)
    }
    
    func applyConstraints() {
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: answerReplyButton.trailingAnchor, constant: 25).isActive = true
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: answerReplyButton.bottomAnchor, constant: 75).isActive = true
        answerReplyButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        answerReplyButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
}

enum SectionTypes: Int {
    case post = 0
    case answers = 1
}

extension PostDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //[0]Post, [1]=Answers
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SectionTypes.post.rawValue {
            return nil
        }
        return "\(post?.answersCount ?? 0) Answers"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SectionTypes.post.rawValue {
            return 1
        } else {
            return post?.answers.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //The original question/post
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.detailedPostCellId, for: indexPath)
            as! DetailedPostCell
            
            cell.postTitleLabel.text = post?.title
            cell.posterNameLabel.text = (post?.createdBy?.information?.fullName ?? "Anonymous")
            cell.posterDetailLabel.text = "Posted \((post?.dateCreated?.toDisplayFormat() ?? "Tool"))"
            
            cell.postBodyLabel.text = post?.description
            
            //this mocking logic if a post has an image attached
            if let hasPhoto = post?.imagePath {
                cell.photoHeightConstraint.constant = CGFloat(FeedViewController.IMAGE_HEIGHT)
                
                // Set default image for placeholder
                let placeholderImage = UIImage(named:"squat1")!
                
                // Get a reference to the storage service using the default Firebase App
                let storage = Storage.storage()
                let pathname = K.Firestore.Storage.IMAGES_ROOT_DIR + "/" + (post?.imagePath ?? "")
                
                // Create a reference with an initial file path and name
                let storagePathReference = storage.reference(withPath: pathname)
                
                // Load the image using SDWebImage
                
                cell.photoView.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
            } else {
                cell.photoHeightConstraint.constant = 0 //CGFloat(FeedViewController.IMAGE_HEIGHT)
                cell.photoView.isHidden = true
            }
            
            return cell
             
        } else { //The answers
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Storyboard.answerCellId, for: indexPath)
                as! AnswerPostCell
                    
            let answer = post?.answers[indexPath.row]
            cell.answerBodyLabel.text = answer?.text
            cell.answererNameLabel.text = answer?.createdBy?.information?.fullName
            cell.answererInfoLabel.text = answer?.createdBy?.information?.salutation
            //TODO: Do something with like count label since that is gone @Miguel. Perhaps show total votes instead?
            
            return cell
        }

    }
}

extension PostDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.section). \(indexPath.row)")
        
    }
}
