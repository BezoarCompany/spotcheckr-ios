import MaterialComponents

class AnswerCell : MDCCardCollectionCell {
    lazy var widthConstraint: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    var votingControls: VotingControls = {
        let controls = VotingControls()
        controls.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    var overflowMenuTap: (() -> Void)? = nil
    private var overflowMenuLayoutConstraints: [NSLayoutConstraint]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
                
        applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        addSubviews()
        applyConstraints()
        initControls()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        widthConstraint.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func addSubviews() {
        //contentView.addSubview(thumbnailImageView)
        contentView.addSubview(headerLabel)
        contentView.addSubview(subHeadLabel)
        contentView.addSubview(supportingTextLabel)
        contentView.addSubview(votingControls)
        contentView.addSubview(overflowMenu)
    }
    
    func applyConstraints() {
        overflowMenuLayoutConstraints = [overflowMenu.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
               contentView.trailingAnchor.constraint(equalTo: overflowMenu.trailingAnchor, constant: 8),
               contentView.bottomAnchor.constraint(equalTo: overflowMenu.bottomAnchor, constant: 16)]
        
        NSLayoutConstraint.activate([
            
//        thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//        thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//        thumbnailImageView.widthAnchor.constraint(equalToConstant: 40),
//        thumbnailImageView.heightAnchor.constraint(equalToConstant: 40),

        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        subHeadLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
        subHeadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        supportingTextLabel.topAnchor.constraint(equalTo: subHeadLabel.bottomAnchor, constant: 16),
        supportingTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        supportingTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
        votingControls.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
        contentView.bottomAnchor.constraint(equalTo: votingControls.bottomAnchor, constant: 16),
        ])
        NSLayoutConstraint.activate(overflowMenuLayoutConstraints)
    }
    
    func initControls() {
        overflowMenu.view.addTarget(self, action: #selector(overflowMenuOnTapped(_:)), for: .touchUpInside)
    }
    
    func setOverflowMenuLocation(location: OverflowMenuLocation) {
        for constraint in overflowMenuLayoutConstraints {
            constraint.isActive = false
        }
        
        if location == .bottom {
            overflowMenuLayoutConstraints = [overflowMenu.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: overflowMenu.trailingAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: overflowMenu.bottomAnchor, constant: 16)]
        }
        else {
            overflowMenuLayoutConstraints = [overflowMenu.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: overflowMenu.trailingAnchor, constant: 8)]
        }
        
        NSLayoutConstraint.activate(overflowMenuLayoutConstraints!)
    }
    
    @objc func overflowMenuOnTapped(_ sender: Any) {
        if let event = overflowMenuTap {
            event()
        }
    }
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body2
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
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
        image.image = Images.profilePictureDefault
        image.tintColor = .white
        //TODO: Clicking on the image should take you to its location.
        return image
    }()
    
    let supportingTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body2
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let overflowMenu: FlatButton = {
        let button = FlatButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.view.setImage(Images.moreHorizontal, for: .normal)
        button.view.setImageTintColor(ApplicationScheme.instance.containerScheme.colorScheme.onSurfaceColor, for: .normal)
        return button
    }()
}
