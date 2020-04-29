import UIKit
import MaterialComponents

class PrivacySettingsViewController: UIViewController {
    let appBarViewController = UIElementFactory.getAppBar()
    let collectionView: CollectionView = {
        let view = CollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let snackbarMessage: MDCSnackbarMessage = {
        let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
        return message
    }()
    var isAnalyticsCollectionEnabled = false
    var analyticsPreferenceCell: SettingsCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppBar()
        initCollectionView()
        applyConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isAnalyticsCollectionEnabled = Services.analyticsService.getCollectionEnabled()
        analyticsPreferenceCell?.switchView.content.addTarget(self,
                                                              action: #selector(setAnalytics(sender:)),
                                                              for: .touchUpInside)
        collectionView.contentView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addChild(appBarViewController)
    }
    
    private func applyConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: appBarViewController.navigationBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            safeArea.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            safeArea.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
    }
    
    private func initAppBar() {
        appBarViewController.didMove(toParent: self)
        appBarViewController.navigationBar.title = "Privacy"
        appBarViewController.navigationBar.backItem = UIBarButtonItem(image: Images.back,
                                                                      style: .done,
                                                                      target: self,
                                                                      action: #selector(backOnClick(sender:)))
        view.addSubview(appBarViewController.view)
    }
    
    @objc func backOnClick(sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func setAnalytics(sender: Any) {
        do {
            try Services.analyticsService.setCollectionEnabled(analyticsPreferenceCell!.switchView.content.isOn)
        } catch {
            analyticsPreferenceCell?.switchView.content.setOn(!analyticsPreferenceCell!.switchView.content.isOn,
                                                            animated: true)
            self.snackbarMessage.text = "Unable to set analytics setting."
            MDCSnackbarManager.show(self.snackbarMessage)
        }
    }
}

extension PrivacySettingsViewController: UICollectionViewDataSource,
                                       UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CellLocations.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrivacyCell",
                                                      for: indexPath) as! SettingsCell
        
        let titleLabel = UILabel()
        let detailLabel = UILabel()
    
        switch indexPath.row {
        case CellLocations.analytics.rawValue:
            titleLabel.text = "Analytics"
            detailLabel.text = "Spotcheckr uses analytics to capture crash data, logs, and other usage information."
            cell.switchView.content.setOn(isAnalyticsCollectionEnabled, animated: false)
            analyticsPreferenceCell = cell
        default: break
        }
        
        cell.titleLabel = titleLabel
        cell.detailLabel = detailLabel
        
        return cell
    }
    
    func initCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 1)
        collectionView.contentView.collectionViewLayout = layout
        collectionView.contentView.delegate = self
        collectionView.contentView.dataSource = self
        collectionView.contentView.register(SettingsCell.self, forCellWithReuseIdentifier: "PrivacyCell")
        view.addSubview(collectionView)
    }
    
    enum CellLocations: Int, CaseIterable {
        case analytics
    }
}
