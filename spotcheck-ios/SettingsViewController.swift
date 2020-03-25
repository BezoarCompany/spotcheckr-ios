import UIKit
import MaterialComponents

class SettingsViewController: UIViewController {
    var window: UIWindow?
    let appBarViewController = UIElementFactory.getAppBar()
    let settingsView: UICollectionView = {
       let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    let snackbarMessage: MDCSnackbarMessage = {
       let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
       return message
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAppBar()
        addSubviews()
        initSettingsView()
        applyConstraints()
    }
    
    func initAppBar() {
        appBarViewController.didMove(toParent: self)
    }
    
    func addSubviews() {
        view.addSubview(appBarViewController.view)
        view.addSubview(settingsView)
    }
    
    func initSettingsView() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 1)
        settingsView.collectionViewLayout = layout
        settingsView.delegate = self
        settingsView.dataSource = self
        settingsView.register(MDCSelfSizingStereoCell.self, forCellWithReuseIdentifier: "Cell")
        settingsView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            settingsView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor, constant: 16),
            settingsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor, constant: 55),
        ])
    }
    
    func logout() {
        do {
            try Services.userService.signOut()
            let authViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = authViewController
            self.window?.makeKeyAndVisible()
        } catch {
            self.snackbarMessage.text = "An error occurred signing out."
            MDCSnackbarManager.show(self.snackbarMessage)
        }
    }
}

extension SettingsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
        for: indexPath) as! MDCSelfSizingStereoCell
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        
        switch indexPath.row {
        case CellLocations.Logout.rawValue:
            cell.titleLabel.text = "Log out"
            cell.leadingImageView.image = Images.logOut
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case CellLocations.Logout.rawValue:
            logout()
        default: break
        }
    }
}

enum CellLocations: Int {
    case Logout = 0
}
