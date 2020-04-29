import Foundation
import UIKit

class Divider: UIView {
    let color: UIColor = {
        let onSurfaceColor = ApplicationScheme.instance.containerScheme.colorScheme.onSurfaceColor
        let color = UIColor(red: onSurfaceColor.redValue, green: onSurfaceColor.greenValue, blue: onSurfaceColor.blueValue, alpha: 0.2)
        return color
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let divider = UILabel()
        divider.backgroundColor = color
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: divider.trailingAnchor),
            bottomAnchor.constraint(equalTo: divider.bottomAnchor)
        ])
    }
}
