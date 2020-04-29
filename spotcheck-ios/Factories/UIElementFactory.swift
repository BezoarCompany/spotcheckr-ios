import UIKit
import MaterialComponents

// TODO: Remove usage in favors of components.
///Deprecated: Create custom components instead.
class UIElementFactory {
    static func getLabel() -> UILabel {
        let label = UILabel()
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body2
        return label
    }

    static func getSwitch() -> UISwitch {
        let uiSwitch = UISwitch()
        uiSwitch.onTintColor = ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor
        return uiSwitch
    }

    static func getActionSheet() -> MDCActionSheetController {
        let sheet = MDCActionSheetController()
        sheet.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        return sheet
    }

    static func getAppBar() -> MDCAppBarViewController {
        let vc = MDCAppBarViewController()
        vc.applyPrimaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        return vc
    }

    static func getActivityIndicator() -> MDCActivityIndicator {
        let indicator = MDCActivityIndicator()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.sizeToFit()
        indicator.indicatorMode = .indeterminate
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor]
        return indicator
    }
}
