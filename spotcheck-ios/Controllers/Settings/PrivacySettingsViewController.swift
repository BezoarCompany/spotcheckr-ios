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
    var preferences: Preferences?
    var analyticsSwitch: UISwitch?
    var performanceMonitoringSwitch: UISwitch?
    var loggingSwitch: UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        initAppBar()
        initCollectionView()
        applyConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        preferences = Services.systemService.getPreferences()
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
                                                                      action: #selector(backOnClick(_:)))
        view.addSubview(appBarViewController.view)
    }

    @objc func backOnClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func setAnalytics(_ sender: Any) {
        do {
            try Services.analyticsService.setCollectionEnabled(analyticsSwitch!.isOn)
        } catch {
            analyticsSwitch!.setOn(analyticsSwitch!.isOn, animated: true)
            self.snackbarMessage.text = "Unable to set analytics setting."
            MDCSnackbarManager.show(self.snackbarMessage)
        }
    }

    @objc func setPerformanceMonitoring(_ sender: Any) {
        do {
            //swiftlint:disable line_length
            try Services.analyticsService.setPerformanceMonitoringEnabled(performanceMonitoringSwitch!.isOn)
        } catch {
            //swiftlint:disable line_length
            performanceMonitoringSwitch!.setOn(performanceMonitoringSwitch!.isOn, animated: true)
            self.snackbarMessage.text = "Unable to set performance monitoring setting."
            MDCSnackbarManager.show(self.snackbarMessage)
        }
    }

    @objc func setLogging(_ sender: Any) {
        LogManager.setLoggingEnabled(loggingSwitch!.isOn)
    }
}

extension PrivacySettingsViewController: UICollectionViewDataSource,
                                       UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 88)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CellLocations.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrivacyCell",
                                                      for: indexPath) as! SettingsCell
        cell.switchView.content.removeTarget(self, action: nil, for: .touchUpInside)
        switch indexPath.row {
        case CellLocations.analytics.rawValue:
            cell.titleLabel.text = "Analytics"
            cell.detailLabel.text = "Spotcheckr uses analytics to capture crash data and other usage information."
            cell.switchView.content.setOn(preferences?.analyticsCollectionEnabled ?? false, animated: false)
            cell.switchView.content.addTarget(self,
                                              action: #selector(setAnalytics(_:)),
                                              for: .touchUpInside)
            analyticsSwitch = cell.switchView.content
        case CellLocations.performanceMonitoring.rawValue:
            cell.titleLabel.text = "Performance Monitoring"
            cell.detailLabel.text = "Changes will take effect the next time Spotcheckr restarts."
            cell.switchView.content.setOn(preferences?.performanceMonitoringCollectionEnabled ?? false, animated: false)
            cell.switchView.content.addTarget(self,
                                               action: #selector(setPerformanceMonitoring(_:)),
                                               for: .touchUpInside)
            performanceMonitoringSwitch = cell.switchView.content
        case CellLocations.logging.rawValue:
            cell.titleLabel.text = "Diagnostic Logging"
            cell.detailLabel.text = "Logging allows Spotcheckr to diagnose issues that occur so that they can be fixed in the next release."
            cell.switchView.content.setOn(preferences?.loggingEnabled ?? false, animated: false)
            cell.switchView.content.addTarget(self,
                                               action: #selector(setLogging(_:)),
                                               for: .touchUpInside)
            loggingSwitch = cell.switchView.content
        default: break
        }

        cell.detailLabel.sizeToFit()
        return cell
    }

    func initCollectionView() {
        collectionView.contentView.delegate = self
        collectionView.contentView.dataSource = self
        collectionView.contentView.register(SettingsCell.self, forCellWithReuseIdentifier: "PrivacyCell")
        view.addSubview(collectionView)
    }

    enum CellLocations: Int, CaseIterable {
        case analytics = 0, performanceMonitoring = 1, logging = 2
    }
}
