import MaterialComponents

class FeedCell: MDCCardCollectionCell {
    var widthConstraint: NSLayoutConstraint?
    var supportingTextTopConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)
        applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(headerLabel)
        addSubview(subHeadLabel)
        addSubview(thumbnailImageView)
        addSubview(media)
        addSubview(supportingTextLabel)
        addSubview(upvoteButton)
        addSubview(downvoteButton)
    }
    
    func applyConstraints() {
        supportingTextTopConstraint = supportingTextLabel.topAnchor.constraint(equalTo: subHeadLabel.bottomAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
        headerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
        headerLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 8),
        subHeadLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
        subHeadLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 8),
        thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
        thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
        media.topAnchor.constraint(equalTo: subHeadLabel.bottomAnchor, constant: 16),
        media.widthAnchor.constraint(equalToConstant: contentView.frame.width),
        supportingTextTopConstraint!,
        supportingTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        upvoteButton.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
        upvoteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
        downvoteButton.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
        downvoteButton.leadingAnchor.constraint(equalTo: upvoteButton.trailingAnchor, constant: 8),
        bottomAnchor.constraint(equalTo: upvoteButton.bottomAnchor, constant: 16),
        bottomAnchor.constraint(equalTo: downvoteButton.bottomAnchor, constant: 16),
        ])
    }
    
    func setCellWidth(width: CGFloat) {
        widthConstraint?.constant = width
        widthConstraint?.isActive = true
    }
    
    func setConstraintsWithMedia() {
        supportingTextTopConstraint?.isActive = false
        supportingTextLabel.topAnchor.constraint(equalTo: media.bottomAnchor, constant: 16).isActive = true
    }
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body2
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        return label
    }()
    
    let subHeadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body2
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.primaryColorVariant
        return label
    }()
    
    let thumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let media: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let supportingTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body2
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        return label
    }()
    
    let upvoteButton: MDCFlatButton = {
        let button = MDCFlatButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Images.arrowUp, for: .normal)
        return button
    }()
    
    let downvoteButton: MDCFlatButton = {
        let button = MDCFlatButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Images.arrowDown, for: .normal)
        return button
    }()
}
