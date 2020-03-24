import UIKit
import MaterialComponents

class SettingsViewController: UIViewController {
    let appBarViewController = UIElementFactory.getAppBar()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
         initAppBar()
    }
    
    private func initAppBar() {
        self.appBarViewController.didMove(toParent: self)
    }
    
    private func addSubviews() {
        self.view.addSubview(appBarViewController.view)
    }
}
