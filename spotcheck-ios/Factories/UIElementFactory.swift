import UIKit

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
}
