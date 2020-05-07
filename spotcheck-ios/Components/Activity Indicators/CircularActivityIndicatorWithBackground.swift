import MaterialComponents
import UIKit

class CircularActivityIndicatorWithBackground: UIView {
    let boxSize = 80
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.heightAnchor.constraint(equalToConstant: CGFloat(boxSize)).isActive = true
        self.widthAnchor.constraint(equalToConstant: CGFloat(boxSize)).isActive = true
        self.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 0.67)
        self.layer.cornerRadius = 10
        
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
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor]
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
}
