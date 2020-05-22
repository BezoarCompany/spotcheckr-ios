import MaterialComponents
import UIKit

class CircularActivityIndicator: UIView {
    let boxSize = 80

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
        //indicator.sizeToFit()
        indicator.indicatorMode = .indeterminate
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor]
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    func showBackground() {
        isHidden = true
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: CGFloat(boxSize)),
            widthAnchor.constraint(equalToConstant: CGFloat(boxSize))
        ])
        
        backgroundColor = Colors.lightGray
        layer.cornerRadius = 10
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor]
    }

    func startAnimating() {
        indicator.startAnimating()
        isHidden = false
    }

    func stopAnimating() {
        indicator.stopAnimating()
        isHidden = true
    }
}
