import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit
import SVGKit
import MaterialComponents

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    static let IMAGE_HEIGHT = 200
    
    var db: Firestore!
    
    var posts = [ExercisePost]()
    var refreshControl = UIRefreshControl()
    func viewPostHandler(exercisePost: ExercisePost)  {
                       let postDetailViewController = PostDetailViewController.create(post: exercisePost)

                       self.navigationController?.pushViewController(postDetailViewController, animated: true)
                   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let plusImage = SVGKImage(named: "plus").uiImage.withRenderingMode(.alwaysTemplate)
        let addPostButton = MDCFloatingButton()
        addPostButton.setImage(plusImage, for: .normal)
        addPostButton.translatesAutoresizingMaskIntoConstraints = false
        addPostButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addPostButton.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        tableView.addSubview(addPostButton)
        
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: addPostButton.trailingAnchor, constant: 25).isActive = true
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: addPostButton.bottomAnchor, constant: 25).isActive = true
        addPostButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        addPostButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName:K.Storyboard.postNibName, bundle: nil), forCellReuseIdentifier: K.Storyboard.feedCellId)
        tableView.separatorInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)        
        
        getPosts()
    }
    
    func getPosts() {
        let completePostsDataSet = { ( argPosts: [ExercisePost]) in
            self.posts = argPosts
            self.tableView.reloadData()
        }
        
        Services.exercisePostService.getPosts(success: completePostsDataSet)
    }
    
    @objc func addTapped() {
        let createPostViewController = CreatePostViewController.create(createdPostHandler: self.viewPostHandler)
        self.present(createPostViewController, animated: true)
    }
    
    @objc func refresh() {
        getPosts()
        refreshControl.endRefreshing()
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

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postDetailViewController = PostDetailViewController.create(post: posts[indexPath.row])
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
