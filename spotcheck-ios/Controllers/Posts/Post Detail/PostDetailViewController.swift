import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit
import MaterialComponents
import IGListKit

class PostDetailViewController: UIViewController {
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()

    var postDetailViewModel = PostDetailViewModel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(postDetailViewModel.appBarViewController)
    }

    static func create(postId: ExercisePostID?) -> PostDetailViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        //swiftlint:disable force_cast line_length
        let postDetailViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.PostDetailViewControllerId) as! PostDetailViewController

        postDetailViewController.postDetailViewModel.postId = postId

        return postDetailViewController
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(postDetailViewModel.appBarViewController.view)
        postDetailViewModel.appBarViewController.didMove(toParent: self)

        initCollectionView()
        initAnswersSection()
        initActivityIndicator()
        initReplyButton()
        applyConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        firstly {
            when(fulfilled: Services.exercisePostService.getPost(withId: postDetailViewModel.postId!),
                 Services.userService.getCurrentUser())
        }.done { post, user in
            self.postDetailViewModel.post = post
            self.postDetailViewModel.currentUser = user
            self.postDetailViewModel.appBarViewController.navigationBar.title = "\(self.postDetailViewModel.post?.answersCount ?? 0) Answers"
            self.postDetailViewModel.appBarViewController.navigationBar.leadingBarButtonItem = UIBarButtonItem(image: Images.back,
                                                                                           style: .done,
                                                                                           target: self,
                                                                                           action: #selector(self.backOnClick(sender:)))
            self.adapter.performUpdates(animated: true)
        }.catch { _ in
            self.dismiss(animated: true) {
                self.postDetailViewModel.snackbarMessage.text = "There was an error loading the post."
                MDCSnackbarManager.show(self.postDetailViewModel.snackbarMessage)
            }
        }.finally {
            let answersCenter = (self.postDetailViewModel.collectionView.contentView.frame.height - self.postDetailViewModel.postCellHeight) / 2
            self.postDetailViewModel.answersLoadingIndicator.topAnchor.constraint(equalTo: self.postDetailViewModel.postYAxisAnchor,
                                                              constant: answersCenter).isActive = true
            self.postDetailViewModel.answersLoadingIndicator.indicator.startAnimating()
            firstly {
                Services.exercisePostService.getAnswers(forPostWithId: self.postDetailViewModel.post!.id!)
            }.done { answers in
                self.postDetailViewModel.answers = answers
                self.postDetailViewModel.answersCount = self.postDetailViewModel.answers.count
                self.adapter.performUpdates(animated: true)
            }.catch { (_) in
                self.postDetailViewModel.snackbarMessage.text = "There was an error loading answers."
                MDCSnackbarManager.show(self.postDetailViewModel.snackbarMessage)
            }.finally {
                self.postDetailViewModel.answersLoadingIndicator.indicator.stopAnimating()
                if self.postDetailViewModel.answersCount == 0 {
                    self.postDetailViewModel.defaultAnswersSectionLabel.topAnchor.constraint(equalTo: self.postDetailViewModel.postYAxisAnchor,
                                                                         constant: answersCenter).isActive = true
                    self.postDetailViewModel.defaultAnswersSectionLabel.isHidden = false
                }
            }
        }
    }

    // MARK: - objc Functions
    @objc func addAnswerButton(_ sender: Any) {
        let createAnswerViewController = CreateAnswerViewController.create(post: postDetailViewModel.post)
        self.present(createAnswerViewController, animated: true)
    }

    @objc func backOnClick(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PostDetailViewController {
    func initCollectionView() {
        view.addSubview(postDetailViewModel.collectionView)
        postDetailViewModel.layout.estimatedItemSize = postDetailViewModel.cellEstimatedSize
        postDetailViewModel.collectionView.contentView.collectionViewLayout = postDetailViewModel.layout
        postDetailViewModel.collectionView.contentView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        adapter.collectionView = postDetailViewModel.collectionView.contentView
        adapter.dataSource = self
    }

    func initAnswersSection() {
        postDetailViewModel.collectionView.contentView.addSubview(postDetailViewModel.defaultAnswersSectionLabel)
        postDetailViewModel.collectionView.contentView.addSubview(postDetailViewModel.answersLoadingIndicator)
    }
}

extension PostDetailViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if let post = postDetailViewModel.post {
            return [post] + postDetailViewModel.answers
        }

        return []
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ExercisePost {
            return ExercisePostDetailSectionController()
        }
        else {
            return AnswersSectionController()
        }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension PostDetailViewController {
    func initActivityIndicator() {
        postDetailViewModel.activityIndicator.center = self.view.center
        postDetailViewModel.activityIndicator.hidesWhenStopped = true
        postDetailViewModel.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        postDetailViewModel.collectionView.contentView.addSubview(postDetailViewModel.activityIndicator)
    }

    func initReplyButton() {
        postDetailViewModel.answerReplyButton.addTarget(self, action: #selector(addAnswerButton(_:)), for: .touchUpInside)
        postDetailViewModel.collectionView.contentView.addSubview(postDetailViewModel.answerReplyButton)
    }

    func applyConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            postDetailViewModel.collectionView.topAnchor.constraint(equalTo: postDetailViewModel.appBarViewController.view.bottomAnchor),
            postDetailViewModel.collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            postDetailViewModel.collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            postDetailViewModel.collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -55),
            postDetailViewModel.answerReplyButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            postDetailViewModel.answerReplyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75),
            postDetailViewModel.answerReplyButton.widthAnchor.constraint(equalToConstant: 64),
            postDetailViewModel.answerReplyButton.heightAnchor.constraint(equalToConstant: 64),
            postDetailViewModel.answerReplyButton.leadingAnchor.constraint(equalTo: postDetailViewModel.defaultAnswersSectionLabel.trailingAnchor, constant: 16),
            postDetailViewModel.defaultAnswersSectionLabel.widthAnchor.constraint(equalToConstant: 200),
            postDetailViewModel.answersLoadingIndicator.centerXAnchor.constraint(equalTo: postDetailViewModel.collectionView.centerXAnchor)
        ])
    }
}
