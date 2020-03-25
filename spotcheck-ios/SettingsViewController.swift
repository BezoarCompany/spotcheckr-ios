import UIKit
import MaterialComponents

class SettingsViewController: UIViewController {
    var window: UIWindow?
    let appBarViewController = UIElementFactory.getAppBar()
    let logoutButton: MDCButton = {
        let button = MDCButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        button.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        button.setTitle("Log Out", for: .normal)
        return button
    }()
    let logoutButtonActivityIndicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.sizeToFit()
        indicator.indicatorMode = .indeterminate
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor]
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
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
        view.addSubview(logoutButton)
        logoutButton.addSubview(logoutButtonActivityIndicator)
    }
    
    func initSettingsView() {
        settingsView.delegate = self
        settingsView.dataSource = self
        settingsView.register(MDCBaseCell.self, forCellWithReuseIdentifier: "Cell")
        settingsView.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        logoutButton.addTarget(self, action: #selector(logoutTapped(_:)), for: .touchUpInside)
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            settingsView.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor),
            settingsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor),
            logoutButton.topAnchor.constraint(equalTo: settingsView.bottomAnchor, constant: 8),
            logoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 65),
            logoutButtonActivityIndicator.centerXAnchor.constraint(equalTo: logoutButton.centerXAnchor),
            logoutButtonActivityIndicator.centerYAnchor.constraint(equalTo: logoutButton.centerYAnchor)
        ])
    }
    
    @objc func logoutTapped(_ sender: Any) {
        do {
            logoutButton.setTitle("", for: .normal)
            logoutButtonActivityIndicator.startAnimating()
            try Services.userService.signOut()
            let authViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = authViewController
            self.window?.makeKeyAndVisible()
        } catch {
            logoutButton.setTitle("Log Out", for: .normal)
            logoutButtonActivityIndicator.stopAnimating()
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
        for: indexPath) as! MDCBaseCell
        cell.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        
        return cell
    }
}
