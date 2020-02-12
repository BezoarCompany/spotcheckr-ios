import Foundation
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var certificationsHeadingLabel: UILabel!
    @IBOutlet weak var certificationsLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyStyles()
    }
    
    private func applyStyles() {
        nameLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        nameLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        certificationsLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        certificationsLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        certificationsHeadingLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        certificationsHeadingLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        occupationLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        occupationLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId )
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
}
