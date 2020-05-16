import UIKit
import MaterialComponents
import IGListKit

class PostDetailViewModel {
    // MARK: - Properties
    var post: ExercisePost?
    var postId: ExercisePostID?
    var answers = [Answer]()
    var answersCount = 0
    var currentUser: User?
    var postYAxisAnchor: NSLayoutYAxisAnchor!
    var postCellHeight: CGFloat!
    let cellHeightEstimate = 185.0
    let cellEstimatedSize: CGSize = {
        let width = UIScreen.main.bounds.size.width
        let height = CGFloat(185)
        let size = CGSize(width: width, height: height)
        return size
    }()

    // MARK: - UIElements
    let snackbarMessage: MDCSnackbarMessage = {
        let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
        return message
    }()
    let collectionView: CollectionView = {
        let view = CollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
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
}
