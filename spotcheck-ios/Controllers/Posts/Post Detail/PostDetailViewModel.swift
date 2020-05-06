import UIKit
import MaterialComponents

class PostDetailViewModel {
    var post: ExercisePost?
    var currentUser: User?
    var viewController: UIViewController?
    var postYAxisAnchor: NSLayoutYAxisAnchor!
    var postCellHeight: CGFloat!
    let snackbarMessage: MDCSnackbarMessage = {
        let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
        return message
    }()
}
