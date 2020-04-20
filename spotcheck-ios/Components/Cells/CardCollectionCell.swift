import MaterialComponents

class CardCollectionCell: MDCCardCollectionCell {
    var dividerLeadingConstraint: NSLayoutConstraint?
    var overflowMenuLayoutConstraints: [NSLayoutConstraint]?
    var overflowMenuTap: (() -> Void)? = nil
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
    
    let supportingTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body2
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let cellDivider: Divider = {
        let divider = Divider()
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }()
    
    var votingControls: VotingControls = {
        let controls = VotingControls()
        controls.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    
    let overflowMenu: FlatButton = {
        let button = FlatButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.view.setImage(Images.moreHorizontal, for: .normal)
        button.view.setImageTintColor(ApplicationScheme.instance.containerScheme.colorScheme.onSurfaceColor, for: .normal)
        return button
    }()
    
    let thumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = Images.profilePictureDefault
        image.tintColor = .white
        //TODO: Clicking on the image should take you to its location.
        return image
    }()
    
    let media: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        addSubviews()
        initControls()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
           //contentView.addSubview(thumbnailImageView)
           contentView.addSubview(headerLabel)
           contentView.addSubview(subHeadLabel)
           contentView.addSubview(media)
           contentView.addSubview(supportingTextLabel)
           contentView.addSubview(votingControls)
           contentView.addSubview(overflowMenu)
           contentView.addSubview(cellDivider)
       }
    
    func setOverflowMenuLocation(location: OverflowMenuLocation) {
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
    
    func initControls() {
        overflowMenu.view.addTarget(self, action: #selector(overflowMenuOnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func overflowMenuOnTapped(_ sender: Any) {
        if let event = overflowMenuTap {
            event()
        }
    }
    
    func hideDivider() {
        cellDivider.isHidden = true
    }
    
    func setFullBleedDivider() {
        dividerLeadingConstraint?.constant = 0
    }
}
