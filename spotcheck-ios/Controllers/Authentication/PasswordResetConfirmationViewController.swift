import UIKit
import MaterialComponents.MDCButton

class PasswordResetConfirmationViewController: UIViewController {

    @IBOutlet weak var confirmationHeadline: UILabel!
    @IBOutlet weak var confirmationSubtitle: UILabel!
    @IBOutlet weak var loginReturnButton: MDCButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyling()
    }

    private func applyStyling() {
        self.confirmationHeadline.font = ApplicationScheme.instance.containerScheme.typographyScheme.headline4
        self.confirmationHeadline.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor

        self.confirmationSubtitle.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle1
        self.confirmationSubtitle.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.loginReturnButton.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.loginReturnButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        self.loginReturnButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
    }
}
