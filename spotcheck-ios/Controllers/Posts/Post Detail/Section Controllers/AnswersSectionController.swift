import IGListKit
import MaterialComponents
import PromiseKit

class AnswersSectionController: ListSectionController {
    var answer: Answer!

    override init() {
        super.init()
    }

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: CGFloat(185))
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let controller = self.viewController as? PostDetailViewController

        let cell = collectionContext!.dequeueReusableCell(of: AnswerCell.self, for: self, at: index) as! AnswerCell

        let isLastCell = { (index: Int) in return index == (controller?.viewModel.answersCount)! - 1 }
        if isLastCell(index) {
            cell.hideDivider()
        }
        cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        cell.isInteractable = false
        cell.headerLabel.text = answer.createdBy?.information?.name
        cell.headerLabel.numberOfLines = 0
        cell.subHeadLabel.text = "\(answer.dateCreated?.toDisplayFormat() ?? "")"
        cell.votingControls.upvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteContent(contentId: self.answer.id!,
                                                     userId: (controller?.viewModel.currentUser?.id!)!,
                                                              direction: voteDirection)
        }
        cell.votingControls.downvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteContent(contentId: self.answer.id!,
                                                     userId: (controller?.viewModel.currentUser?.id!)!,
                                                              direction: voteDirection)
        }
        cell.supportingTextLabel.text = answer.text
        cell.supportingTextLabel.numberOfLines = 0
        cell.votingControls.votingUserId = controller?.viewModel.currentUser?.id
        cell.votingControls.voteDirection = answer.metrics?.currentVoteDirection
        cell.votingControls.renderVotingControls()
        cell.cornerRadius = 0
        cell.overflowMenuTap = {
            let actionSheet = UIElementFactory.getActionSheet()
            let reportAction = MDCActionSheetAction(title: "Report", image: Images.flag, handler: { (_) in
                let reportViewController = ReportViewController.create(contentId: self.answer.id)
                controller?.present(reportViewController, animated: true)
            })

            if self.answer.createdBy?.id == controller?.viewModel.currentUser?.id {
                let deleteCommentAction = MDCActionSheetAction(title: "Delete", image: Images.trash) { (_) in
                    let deleteCommentAlertController = MDCAlertController(title: nil,
                                                                          message: "Are you sure you want to delete your comment?")

                let deleteCommentAlertAction = MDCAlertAction(title: "Delete", emphasis: .high, handler: { (_) in
                        //TODO: Show activity indicator
                        firstly {
                            Services.exercisePostService.deleteAnswer(self.answer)
                        }.done {
                            //TODO: Stop animating activity indicator
                            controller?.viewModel.answersCount -= 1
                            controller?.viewModel.appBarViewController.navigationBar.title = "\(controller?.viewModel.answersCount) Answers"
                            //TODO: Delete items
                        }.catch { _ in
                            controller?.viewModel.snackbarMessage.text = "Unable to delete answer."
                            MDCSnackbarManager.show(controller?.viewModel.snackbarMessage)
                        }
                    })

                deleteCommentAlertController.addAction(deleteCommentAlertAction)
                deleteCommentAlertController.addAction(MDCAlertAction(title: "Cancel", emphasis: .high, handler: nil))
                deleteCommentAlertController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
                controller?.present(deleteCommentAlertController, animated: true)
                }
                actionSheet.addAction(deleteCommentAction)
            }

            actionSheet.addAction(reportAction)
            controller?.present(actionSheet, animated: true)
        }
        cell.setOverflowMenuLocation(location: .top)
        return cell
    }

    override func didUpdate(to object: Any) {
        answer = object as? Answer
    }
}
