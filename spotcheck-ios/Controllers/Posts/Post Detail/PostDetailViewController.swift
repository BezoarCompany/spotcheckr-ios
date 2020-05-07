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
        view.addSubview(postDetailViewModel.collectionView)
        postDetailViewModel.layout.estimatedItemSize = postDetailViewModel.cellEstimatedSize
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
        postDetailViewModel.collectionView.contentView.collectionViewLayout = postDetailViewModel.layout
//        collectionView.contentView.delegate = self
//        collectionView.contentView.dataSource = self
//        collectionView.contentView.register(FeedCell.self, forCellWithReuseIdentifier: K.Storyboard.feedCellId)
//        collectionView.contentView.register(AnswerCell.self, forCellWithReuseIdentifier: K.Storyboard.answerCellId)
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
            return [post]
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
