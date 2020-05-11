import MaterialComponents
import UIKit

class CircularActivityIndicator: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            indicator.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: indicator.trailingAnchor),
            bottomAnchor.constraint(equalTo: indicator.bottomAnchor)
        ])
    }

    var indicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.sizeToFit()
        indicator.indicatorMode = .indeterminate
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor]
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
}
