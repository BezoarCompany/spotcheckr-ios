import IGListKit
import MaterialComponents
import FirebaseStorage
import PromiseKit

class ExercisePostDetailSectionController: ListSectionController {
    var post: ExercisePost!

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
        
        let cell = collectionContext!.dequeueReusableCell(of: FeedCell.self, for: self, at: index) as! FeedCell
        cell.setShadowElevation(ShadowElevation(rawValue: 10), for: .normal)
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        cell.isInteractable = false
        cell.headerLabel.text = post.title
        cell.headerLabel.numberOfLines = 0
        cell.subHeadLabel.text = "\(post.dateCreated?.toDisplayFormat() ?? "")"
        cell.votingControls.upvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteContent(contentId: self.post.id!,
                                                     userId: (controller?.postDetailViewModel.currentUser?.id!)!,
                                                     direction: voteDirection)
        }
        cell.votingControls.downvoteOnTap = { (voteDirection: VoteDirection) in
            Services.exercisePostService.voteContent(contentId: (controller?.postDetailViewModel.post?.id!)!,
                                                     userId: (controller?.postDetailViewModel.currentUser?.id!)!,
                                                     direction: voteDirection)
        }

        if post.imagePath != nil {
            // Set default image for placeholder
            let placeholderImage = UIImage(named: "squatLogoPlaceholder")!

            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            let pathname = K.Firestore.Storage.imagesRootDirectory + "/" + (post.imagePath ?? "")

            // Create a reference with an initial file path and name
            let storagePathReference = storage.reference(withPath: pathname)

            // Load the image using SDWebImage
            cell.media.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)

            cell.setConstraintsWithMedia()
            controller?.postDetailViewModel.postCellHeight = cell.frame.height + CGFloat(FeedCell.imageHeight)
        } else {
            cell.setConstraintsWithNoMedia()
            controller?.postDetailViewModel.postCellHeight = cell.frame.height
        }

        if let vidFilename = post.videoPath {
            cell.initVideoPlayer(videoFileName: vidFilename)
        }

        cell.supportingTextLabel.text = post.description
        cell.supportingTextLabel.numberOfLines = 0
        cell.postId = post.id
        cell.post = post
        cell.votingControls.votingUserId = controller?.postDetailViewModel.currentUser?.id
        cell.votingControls.voteDirection = post.metrics.currentVoteDirection
        cell.votingControls.renderVotingControls()
        cell.cornerRadius = 0
        cell.overflowMenuTap = {
            let actionSheet = UIElementFactory.getActionSheet()
            let reportAction = MDCActionSheetAction(title: "Report", image: Images.flag, handler: { (_) in
                let reportViewController = ReportViewController.create(contentId: self.post.id)
                self.viewController?.present(reportViewController, animated: true)
            })

            let editAction = MDCActionSheetAction(title: "Edit", image: Images.edit, handler: { (_) in
                let createPostViewController = CreatePostViewController.create(updatePostMode: .edit,
                                                                               post: self.post)

                //TODO: Update PostDetail after edit, as well as in Feed TableView
                self.viewController?.present(createPostViewController, animated: true)
            })

            let deleteAction = MDCActionSheetAction(title: "Delete", image: Images.trash) { (_) in
                let deleteAlertController = MDCAlertController(title: "Are you sure you want to delete this post?",
                                                               message: "This will delete all included answers too.")

                let deleteAlertAction = MDCAlertAction(title: "Delete", emphasis: .high, handler: { (_) in
                    //self.activityIndicator.startAnimating()

                    firstly {
                        Services.exercisePostService.deletePost(self.post)
                    }.done {
                        //self.activityIndicator.stopAnimating()
                        self.viewController?.navigationController?.popViewController(animated: true)
                    }.catch { _ in
                        //self.activityIndicator.stopAnimating()

                        self.viewController?.navigationController?.popViewController(animated: true)
                        controller?.postDetailViewModel.snackbarMessage.text = "Error deleting post."
                        MDCSnackbarManager.show(controller?.postDetailViewModel.snackbarMessage)
                    }
                })

                deleteAlertController.addAction(deleteAlertAction)
                deleteAlertController.addAction(MDCAlertAction(title: "Cancel", emphasis: .high, handler: nil))
                deleteAlertController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)

                self.viewController?.present(deleteAlertController, animated: true, completion: nil)
            }

            if controller?.postDetailViewModel.currentUser?.id == self.post.createdBy?.id {
                actionSheet.addAction(editAction)
                actionSheet.addAction(deleteAction)
            }
            actionSheet.addAction(reportAction)

            self.viewController?.present(actionSheet, animated: true)
        }
        cell.setOverflowMenuLocation(location: .top)
        cell.setFullBleedDivider()
        controller?.postDetailViewModel.postYAxisAnchor = cell.bottomAnchor
        return cell
    }

    override func didUpdate(to object: Any) {
        post = object as? ExercisePost
    }
}
