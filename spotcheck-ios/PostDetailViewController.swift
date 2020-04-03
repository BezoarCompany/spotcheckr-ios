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
    var tableView: UITableView!
    
    @IBAction func addAnswerButton(_ sender: Any) {
        let createAnswerViewController = CreateAnswerViewController.create(post: post)
        self.present(createAnswerViewController, animated: true)
    }
    
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    typealias DiffedPostsDataUpdateClosureType = ((_ diffType: DiffType, _ post: ExercisePost) -> Void) //takes diff type, and post to be modified
    var diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? //To dynamically update UITableView with the new post
    
    func updatePostDetail(argPost: ExercisePost) {
        self.post = argPost
        let idxPath = IndexPath(row: 0, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [idxPath], with: .automatic)
        self.tableView.endUpdates()
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
        
        initDetail()
        initActivityIndicator()
        initReplyButton()
        applyConstraints()
        
        firstly {
            Services.exercisePostService.getPost(withId: postId!)
        }.done { post in
            self.post = post
            self.appBarViewController.navigationBar.title = "\(self.post?.answers.count ?? 0) Answers"
            self.appBarViewController.navigationBar.leadingBarButtonItem = UIBarButtonItem(image: Images.back, style: .done, target: self, action: #selector(self.backOnClick(sender:)))
            self.tableView.reloadData()
        }
        
        //access control for the modify menu
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            if let postUserId = self.post?.createdBy?.id, postUserId == user.id{
                self.appBarViewController.navigationBar.trailingBarButtonItem = UIBarButtonItem(image: Images.edit, style: .plain, target: self, action: #selector(self.modifyPost))
            }
        }
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
    
    func initDetail() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        tableView.dataSource = self
        tableView.register(UINib(nibName:K.Storyboard.detailedPostNibName , bundle: nil), forCellReuseIdentifier: K.Storyboard.detailedPostCellId)
        tableView.register(UINib(nibName:K.Storyboard.answerNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.answerCellId)
        tableView.addSubview(answerReplyButton)
        tableView.separatorInset = UIEdgeInsets(top: -10,left: 0,bottom: 0,right: 0)
        view.addSubview(tableView)
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
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -55),
            answerReplyButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor , constant: -20),
            answerReplyButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -75),
            answerReplyButton.widthAnchor.constraint(equalToConstant: 64),
            answerReplyButton.heightAnchor.constraint(equalToConstant: 64),
        ])
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
            cell.posterNameLabel.text = (post?.createdBy?.information?.name ?? "Anonymous")
            cell.posterDetailLabel.text = "\(post?.dateCreated?.toDisplayFormat() ?? "")"
            
            cell.postBodyLabel.text = post?.description
            
            //this mocking logic if a post has an image attached
            if let imagePath = post?.imagePath {
                let placeholderImage = UIImage(named:"squatLogoPlaceholder")!
                
                let storage = Storage.storage()
                let pathname = K.Firestore.Storage.IMAGES_ROOT_DIR + "/" + (imagePath)
                
                let storagePathReference = storage.reference(withPath: pathname)
                cell.photoView.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
                cell.photoHeightConstraint.constant = CGFloat(FeedCell.IMAGE_HEIGHT)
                cell.photoView.isHidden = false
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
            cell.answererNameLabel.text = answer?.createdBy?.information?.name
            
            //TODO: Profile upload. Adding placeholder b/c it looks to visually jarring and hard to distinguish the different answers without the profile pic cue
            if let picturePath = post?.createdBy?.profilePicturePath {
                let placeholderImage = UIImage(systemName: "person.crop.circle")!
                let storage = Storage.storage()
                let storagePathReference = storage.reference(withPath: picturePath)
                cell.thumbnailImageView.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
            }
            
            return cell
        }

    }
}
