import Foundation
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyStyles()
    }
    
    private func applyStyles() {
        logoutButton.setTitleTextAttributes(
            [
            NSAttributedString.Key.font: ApplicationScheme.instance.containerScheme.typographyScheme.button,
            NSAttributedString.Key.foregroundColor: ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor], for: .normal)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId )
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
}
