import UIKit

class RefreshControl: UIRefreshControl {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init() {
        super.init()
        self.tintColor = .clear
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        activityIndicator.indicator.startAnimating()
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        activityIndicator.indicator.stopAnimating()
    }
    
    private let activityIndicator: CircularActivityIndicator = {
        let activityIndicator = CircularActivityIndicator()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
}
