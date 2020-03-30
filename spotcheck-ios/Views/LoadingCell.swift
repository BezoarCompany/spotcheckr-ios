import MaterialComponents
import PromiseKit

class LoadingCell: MDCCardCollectionCell {
    static let cellId = "LoadingCell"
    
    var widthConstraint: NSLayoutConstraint?
    var activityIndicator = UIElementFactory.getActivityIndicator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: frame.width)
        applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        
        addSubview(activityIndicator)
        
        applyConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellWidth(width: CGFloat) {
        widthConstraint?.constant = width
        widthConstraint?.isActive = true
        
        activityIndicator.startAnimating()
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo:contentView.topAnchor, constant: 20),
            activityIndicator.leadingAnchor.constraint(equalTo:contentView.leadingAnchor, constant: frame.width/2-10),
            contentView.bottomAnchor.constraint(equalTo:activityIndicator.bottomAnchor, constant: 0),
        ])
    }
}
