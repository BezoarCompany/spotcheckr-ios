import Foundation
import MaterialComponents
import UIKit

class FlatButton: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.widthAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        view.layer.cornerRadius = 0.5 * view.frame.width
        view.clipsToBounds = true
    }
    
    let view: MDCButton = {
        let button = MDCButton()
        button.applyTextTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setImageTintColor(ApplicationScheme.instance.containerScheme.colorScheme.onSurfaceColor, for: .highlighted)
    
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
