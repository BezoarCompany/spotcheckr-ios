import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit
import MaterialComponents
import IGListKit

class PostDetailViewController: UIViewController {
    // MARK: - UI Elements
    let collectionView: CollectionView = {
        let view = CollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
    }()
    let cellHeightEstimate = 185.0
    let cellEstimatedSize: CGSize = {
        let width = UIScreen.main.bounds.size.width
        let height = CGFloat(185)
        let size = CGSize(width: width, height: height)
        return size
    }()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let appBarViewController = UIElementFactory.getAppBar()
    let answerReplyButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Images.reply, for: .normal)
        return button
    }()
    let defaultAnswersSectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "There are no answers, be the first to help!"
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        return label
    }()
    let answersLoadingIndicator: CircularActivityIndicator = {
        let indicator = CircularActivityIndicator()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()

    // MARK: - Properties
    var postId: ExercisePostID?
    var postDetailSectionModel: ExercisePostDetailSectionModel?
    var postDetailViewModel = PostDetailViewModel()
    var answers = [Answer]()
    var answersCount = 0

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }

    static func create(postId: ExercisePostID?) -> PostDetailViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        //swiftlint:disable force_cast line_length
        let postDetailViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.PostDetailViewControllerId) as! PostDetailViewController

        postDetailViewController.postId = postId

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
    }

    override func viewDidAppear(_ animated: Bool) {
        firstly {
            when(fulfilled: Services.exercisePostService.getPost(withId: postId!),
                 Services.userService.getCurrentUser())
        }.done { post, user in
            self.postDetailViewModel.post = post
            self.postDetailViewModel.currentUser = user
            self.postDetailViewModel.viewController = self
            self.appBarViewController.navigationBar.title = "\(self.postDetailViewModel.post?.answersCount ?? 0) Answers"
            self.appBarViewController.navigationBar.leadingBarButtonItem = UIBarButtonItem(image: Images.back,
                                                                                           style: .done,
                                                                                           target: self,
                                                                                           action: #selector(self.backOnClick(sender:)))
            self.postDetailSectionModel = ExercisePostDetailSectionModel()
            self.postDetailSectionModel?.screen = self.postDetailViewModel
            self.adapter.performUpdates(animated: true)
        }.catch { _ in
            self.dismiss(animated: true) {
                self.postDetailViewModel.snackbarMessage.text = "There was an error loading the post."
                MDCSnackbarManager.show(self.postDetailViewModel.snackbarMessage)
            }
        }.finally {
//            let answersCenter = (self.collectionView.contentView.frame.height - self.postCellHeight) / 2
//            self.answersLoadingIndicator.topAnchor.constraint(equalTo: self.postYAxisAnchor,
//                                                              constant: answersCenter).isActive = true
//            self.answersLoadingIndicator.indicator.startAnimating()
//            firstly {
//                Services.exercisePostService.getAnswers(forPostWithId: self.post!.id!)
//            }.done { answers in
//                self.answers = answers
//                self.answersCount = self.answers.count
//                self.collectionView.contentView.reloadData()
//            }.catch { (_) in
//                self.snackbarMessage.text = "There was an error loading answers."
//                MDCSnackbarManager.show(self.snackbarMessage)
//            }.finally {
//                self.answersLoadingIndicator.indicator.stopAnimating()
//                if self.answersCount == 0 {
//                    self.defaultAnswersSectionLabel.topAnchor.constraint(equalTo: self.postYAxisAnchor,
//                                                                         constant: answersCenter).isActive = true
//                    self.defaultAnswersSectionLabel.isHidden = false
//                }
            //}
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

//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch section {
//        case CollectionViewSections.postInformation.rawValue:
//            return 1
//        case CollectionViewSections.answers.rawValue:
//            return answers.count
//        default:
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let answer = answers[indexPath.row]
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Storyboard.answerCellId,
//                                                      for: indexPath) as! AnswerCell
//        let isLastCell = { (indexPath: IndexPath) in return indexPath.row == self.answersCount - 1 }
//        if isLastCell(indexPath) {
//            cell.hideDivider()
//        }
//        cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
//        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
//        cell.isInteractable = false
//        cell.headerLabel.text = answer.createdBy?.information?.name
//        cell.headerLabel.numberOfLines = 0
//        cell.subHeadLabel.text = "\(answer.dateCreated?.toDisplayFormat() ?? "")"
//        cell.votingControls.upvoteOnTap = { (voteDirection: VoteDirection) in
//            Services.exercisePostService.voteContent(contentId: answer.id!,
//                                                     userId: (self.currentUser?.id!)!,
//                                                              direction: voteDirection)
//        }
//        cell.votingControls.downvoteOnTap = { (voteDirection: VoteDirection) in
//            Services.exercisePostService.voteContent(contentId: answer.id!,
//                                                     userId: (self.currentUser?.id!)!,
//                                                              direction: voteDirection)
//        }
//        cell.supportingTextLabel.text = answer.text
//        cell.supportingTextLabel.numberOfLines = 0
//        cell.votingControls.votingUserId = currentUser?.id
//        cell.votingControls.voteDirection = answer.metrics?.currentVoteDirection
//        cell.votingControls.renderVotingControls()
//        cell.cornerRadius = 0
//        cell.overflowMenuTap = {
//            let actionSheet = UIElementFactory.getActionSheet()
//            let reportAction = MDCActionSheetAction(title: "Report", image: Images.flag, handler: { (_) in
//                let reportViewController = ReportViewController.create(contentId: answer.id)
//                self.present(reportViewController, animated: true)
//            })
//
//            if answer.createdBy?.id == self.currentUser?.id {
//                let deleteCommentAction = MDCActionSheetAction(title: "Delete", image: Images.trash) { (_) in
//                    let deleteCommentAlertController = MDCAlertController(title: nil,
//                                                                          message: "Are you sure you want to delete your comment?")
//
//                let deleteCommentAlertAction = MDCAlertAction(title: "Delete", emphasis: .high, handler: { (_) in
//                        //TODO: Show activity indicator
//                        firstly {
//                            Services.exercisePostService.deleteAnswer(answer)
//                        }.done {
//                            //TODO: Stop animating activity indicator
//                            self.answersCount -= 1
//                            self.appBarViewController.navigationBar.title = "\(self.answersCount) Answers"
//                            collectionView.deleteItems(at: [indexPath])
//                        }.catch { _ in
//                            self.snackbarMessage.text = "Unable to delete answer."
//                            MDCSnackbarManager.show(self.snackbarMessage)
//                        }
//                    })
//
//                deleteCommentAlertController.addAction(deleteCommentAlertAction)
//                deleteCommentAlertController.addAction(MDCAlertAction(title: "Cancel", emphasis: .high, handler: nil))
//                deleteCommentAlertController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
//                self.present(deleteCommentAlertController, animated: true)
//                }
//                actionSheet.addAction(deleteCommentAction)
//            }
//
//            actionSheet.addAction(reportAction)
//            self.present(actionSheet, animated: true)
//        }
//        cell.setOverflowMenuLocation(location: .top)
//        return cell
//    }

    func initCollectionView() {
        view.addSubview(collectionView)
        layout.estimatedItemSize = cellEstimatedSize
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
        collectionView.contentView.collectionViewLayout = layout
//        collectionView.contentView.delegate = self
//        collectionView.contentView.dataSource = self
//        collectionView.contentView.register(FeedCell.self, forCellWithReuseIdentifier: K.Storyboard.feedCellId)
//        collectionView.contentView.register(AnswerCell.self, forCellWithReuseIdentifier: K.Storyboard.answerCellId)
        collectionView.contentView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        adapter.collectionView = collectionView.contentView
        adapter.dataSource = self
    }

    func initAnswersSection() {
        collectionView.contentView.addSubview(defaultAnswersSectionLabel)
        collectionView.contentView.addSubview(answersLoadingIndicator)
    }
}

extension PostDetailViewController: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if let postDetailViewModel = postDetailSectionModel {
            return [postDetailViewModel]
        }

        return []
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ExercisePostDetailSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension PostDetailViewController {
    func initActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        collectionView.contentView.addSubview(activityIndicator)
    }

    func initReplyButton() {
        answerReplyButton.addTarget(self, action: #selector(addAnswerButton(_:)), for: .touchUpInside)
        collectionView.contentView.addSubview(answerReplyButton)
    }

    func applyConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -55),
            answerReplyButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            answerReplyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75),
            answerReplyButton.widthAnchor.constraint(equalToConstant: 64),
            answerReplyButton.heightAnchor.constraint(equalToConstant: 64),
            answerReplyButton.leadingAnchor.constraint(equalTo: defaultAnswersSectionLabel.trailingAnchor, constant: 16),
            defaultAnswersSectionLabel.widthAnchor.constraint(equalToConstant: 200),
            answersLoadingIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
        ])
    }
}
