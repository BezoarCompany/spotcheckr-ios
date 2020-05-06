import MaterialComponents
import PromiseKit

class LoadingCell: MDCCardCollectionCell {
    static let cellId = "LoadingCell"
    static let cellHeight = 67

    var widthConstraint: NSLayoutConstraint?
    var activityIndicator = UIElementFactory.getActivityIndicator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: frame.width)

        let containerScheme = MDCContainerScheme()
        let colorScheme = MDCSemanticColorScheme()

        colorScheme.surfaceColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
        containerScheme.colorScheme = colorScheme

        applyTheme(withScheme: containerScheme)

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
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: frame.width/2-10),
            contentView.bottomAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 0)
        ])
    }
}
