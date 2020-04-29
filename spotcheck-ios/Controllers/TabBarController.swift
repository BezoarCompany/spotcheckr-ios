import UIKit
import MaterialComponents

class TabBarController: UITabBarController, MDCBottomNavigationBarDelegate {
    let bottomNav = MDCBottomNavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initBottomNavigation()
    }

    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        layoutBottomNavBar()
    }

    func layoutBottomNavBar() {
        let size = bottomNav.sizeThatFits(view.bounds.size )
        var bottomNavBarFrame = CGRect(x: 0,
                                      y: view.bounds.height - size.height,
                                      width: size.width,
                                      height: size.height)
        if #available(iOS 11.0, *) {
          bottomNavBarFrame.size.height += view.safeAreaInsets.bottom
          bottomNavBarFrame.origin.y -= view.safeAreaInsets.bottom
        }

        bottomNav.frame = bottomNavBarFrame
    }

    func initBottomNavigation() {
        bottomNav.applyPrimaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        bottomNav.items = [
            UITabBarItem(title: "Feed", image: Images.list, tag: 0),
            UITabBarItem(title: "Profile", image: Images.user, tag: 1),
            UITabBarItem(title: "Settings", image: Images.settings, tag: 2)
        ]
        bottomNav.titleVisibility = .always
        bottomNav.selectedItem = bottomNav.items[0]

        bottomNav.delegate = self
        view.addSubview(bottomNav)

    }
    func bottomNavigationBar(_ bottomNavigationBar: MDCBottomNavigationBar, didSelect item: UITabBarItem) {
        self.selectedIndex = item.tag
    }
}
