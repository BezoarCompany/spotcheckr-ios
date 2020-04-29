import UIKit
import MaterialComponents
import StoreKit

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
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor, constant: 55)
        ])
    }
}

extension SettingsViewController {
    private func logout() {
        do {
            try Services.userService.signOut()
            let authViewController = UIStoryboard(name: "Main", bundle: nil)
                                     .instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = authViewController
            window?.makeKeyAndVisible()
        } catch {
            snackbarMessage.text = "An error occurred signing out."
            MDCSnackbarManager.show(snackbarMessage)
        }
    }

    private func rate() {
        if let writeReviewURL = URL(string: "https://itunes.apple.com/app/id\(K.App.iTunesId)?action=write-review") {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        } else {
            snackbarMessage.text = "Error going to the App Store."
            MDCSnackbarManager.show(snackbarMessage)
        }
    }
    
    private func clearCache() {
        CacheManager.clearAllCaches()
        snackbarMessage.text = "All caches cleared."
        MDCSnackbarManager.show(snackbarMessage)
    }
    
    private func navigateTo(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SettingsViewController: UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CellLocations.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
        for: indexPath) as! MDCSelfSizingStereoCell
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        
        switch indexPath.row {
        case CellLocations.privacy.rawValue:
            cell.titleLabel.text = "Privacy"
            cell.leadingImageView.image = Images.lock
            cell.trailingImageView.image = Images.chevronRight
        case CellLocations.logout.rawValue:
            cell.titleLabel.text = "Log out"
            cell.leadingImageView.image = Images.logOut
        case CellLocations.rate.rawValue:
            cell.titleLabel.text = "Rate Spotcheckr"
            cell.leadingImageView.image = Images.heart
        case CellLocations.clearCache.rawValue:
            cell.titleLabel.text = "Clear cache"
            cell.leadingImageView.image = Images.database
        case CellLocations.buildVersion.rawValue:
            cell.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.isUserInteractionEnabled = false
            cell.titleLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                cell.titleLabel.text = "v.\(version)"
            }
            cell.titleLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.primaryColorVariant
            cell.titleLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle2
        default:
            break
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case CellLocations.privacy.rawValue:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PrivacySettingsViewController") as! PrivacySettingsViewController
            navigationController?.pushViewController(vc, animated: true)
            //navigateTo(viewController: controller)
        case CellLocations.logout.rawValue:
            logout()
        case CellLocations.rate.rawValue:
            rate()
        case CellLocations.clearCache.rawValue:
            clearCache()
        default: break
        }
    }
    
    enum CellLocations: Int, CaseIterable {
        case privacy
        case clearCache
        case rate
        case logout
        case buildVersion
    }
}

