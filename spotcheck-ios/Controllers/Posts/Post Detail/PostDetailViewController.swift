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
    var viewModel = PostDetailViewModel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(viewModel.appBarViewController)
    }

    static func create(postId: ExercisePostID?) -> PostDetailViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        //swiftlint:disable force_cast line_length

        let postDetailViewController = PostDetailViewController()

        postDetailViewController.viewModel.postId = postId

        return postDetailViewController
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(viewModel.appBarViewController.view)
        viewModel.appBarViewController.didMove(toParent: self)

        initCollectionView()
        initAnswersSection()
        initActivityIndicator()
        initReplyButton()
        applyConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        _ = loadPostDetail()
    }

    // MARK: - objc Functions
    @objc func addAnswerButton(_ sender: Any) {
        let createAnswerViewController = CreateAnswerViewController.create(post: viewModel.post)
        self.present(createAnswerViewController, animated: true)
    }

    @objc func backOnClick(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func refreshPostDetail(_ sender: Any) {
        self.viewModel.collectionView.refreshControl.beginRefreshing()
        firstly {
            loadPostDetail(bypassCache: true)
        }.done {
            self.perform(#selector(self.finishRefreshing), with: nil, afterDelay: 0.1)
        }.catch { _ in
            self.viewModel.snackbarMessage.text = "Error refreshing post."
            MDCSnackbarManager.show(self.viewModel.snackbarMessage)
        }
    }

    @objc func finishRefreshing(_ sender: Any) {
        self.viewModel.collectionView.refreshControl.endRefreshing()
    }
}

// MARK: - Functions
extension PostDetailViewController {
    func loadPostDetail(bypassCache: Bool = false) -> Promise<Void> {
        return Promise { promise in
            firstly {
                when(fulfilled:
                    Services.exercisePostService.getPost(withId: viewModel.postId!, bypassCache: bypassCache),
                     Services.userService.getCurrentUser())
            }.done { post, user in
                self.viewModel.post = post
                self.viewModel.currentUser = user
                self.viewModel.appBarViewController.navigationBar.title = "\(self.viewModel.post?.answersCount ?? 0) Answers"
                self.viewModel.appBarViewController.navigationBar.leadingBarButtonItem = UIBarButtonItem(image: Images.back,
                                                                                                         style: .done,
                                                                                                         target: self,
                                                                                                         action: #selector(self.backOnClick(sender:)))
                self.adapter.performUpdates(animated: true)
            }.catch { error in
                self.dismiss(animated: true) {
                    self.viewModel.snackbarMessage.text = "There was an error loading the post."
                    MDCSnackbarManager.show(self.viewModel.snackbarMessage)
                    return promise.reject(error)
                }
            }.finally {
                let answersCenter = (self.viewModel.collectionView.contentView.frame.height - self.viewModel.postCellHeight) / 2
                self.viewModel.answersLoadingIndicator.topAnchor.constraint(equalTo: self.viewModel.postYAxisAnchor,
                                                                            constant: answersCenter).isActive = true
                self.viewModel.answersLoadingIndicator.indicator.startAnimating()
                firstly {
                    Services.exercisePostService.getAnswers(forPostWithId: self.viewModel.post!.id!, bypassCache: bypassCache)
                }.done { answers in
                    self.viewModel.answers = answers
                    self.viewModel.answersCount = self.viewModel.answers.count
                    self.adapter.performUpdates(animated: true)
                }.catch { (error) in
                    self.viewModel.snackbarMessage.text = "There was an error loading answers."
                    MDCSnackbarManager.show(self.viewModel.snackbarMessage)
                    return promise.reject(error)
                }.finally {
                    self.viewModel.answersLoadingIndicator.indicator.stopAnimating()
                    if self.viewModel.answersCount == 0 {
                        self.viewModel.defaultAnswersSectionLabel.topAnchor.constraint(equalTo: self.viewModel.postYAxisAnchor,
                                                                                       constant: answersCenter).isActive = true
                        self.viewModel.defaultAnswersSectionLabel.isHidden = false
                    }
                    return promise.fulfill_()
                }
            }
        }
    }

    func initCollectionView() {
        viewModel.layout.estimatedItemSize = viewModel.cellEstimatedSize
        viewModel.collectionView.contentView.collectionViewLayout = viewModel.layout
        viewModel.collectionView.contentView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        viewModel.collectionView.contentView.alwaysBounceVertical = true
        viewModel.collectionView.refreshControl.addTarget(self, action: #selector(refreshPostDetail), for: .valueChanged)

        adapter.collectionView = viewModel.collectionView.contentView
        adapter.dataSource = self

        view.addSubview(viewModel.collectionView)
        viewModel.collectionView.attachRefreshControl()
    }

    func initAnswersSection() {
        viewModel.collectionView.contentView.addSubview(viewModel.defaultAnswersSectionLabel)
        viewModel.collectionView.contentView.addSubview(viewModel.answersLoadingIndicator)
    }

    func initActivityIndicator() {
        viewModel.activityIndicator.center = self.view.center
        viewModel.activityIndicator.hidesWhenStopped = true
        viewModel.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        viewModel.collectionView.contentView.addSubview(viewModel.activityIndicator)
    }

    func initReplyButton() {
        viewModel.answerReplyButton.addTarget(self, action: #selector(addAnswerButton(_:)), for: .touchUpInside)
        viewModel.collectionView.contentView.addSubview(viewModel.answerReplyButton)
    }

    func applyConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            viewModel.collectionView.topAnchor.constraint(equalTo: viewModel.appBarViewController.view.bottomAnchor),
            viewModel.collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            viewModel.collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            viewModel.collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -55),
            viewModel.answerReplyButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            viewModel.answerReplyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75),
            viewModel.answerReplyButton.widthAnchor.constraint(equalToConstant: 64),
            viewModel.answerReplyButton.heightAnchor.constraint(equalToConstant: 64),
            viewModel.answerReplyButton.leadingAnchor.constraint(equalTo: viewModel.defaultAnswersSectionLabel.trailingAnchor, constant: 16),
            viewModel.defaultAnswersSectionLabel.widthAnchor.constraint(equalToConstant: 200),
            viewModel.answersLoadingIndicator.centerXAnchor.constraint(equalTo: viewModel.collectionView.centerXAnchor)
        ])
    }
}

// MARK: - List Adapter
extension PostDetailViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if let post = viewModel.post {
            return [post] + viewModel.answers
        }

        return []
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is ExercisePost {
            return ExercisePostDetailSectionController()
        } else {
            return AnswersSectionController()
        }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
