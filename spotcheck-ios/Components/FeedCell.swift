import MaterialComponents
import PromiseKit

enum OverflowMenuLocation {
    case top, bottom
}

class FeedCell: MDCCardCollectionCell {
    static let IMAGE_HEIGHT = 200
    
    lazy var widthConstraint: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()    
    
    var postId: String?
    var mediaHeightConstraint: NSLayoutConstraint?
    var post: ExercisePost?
    var votingControls: VotingControls = {
        let controls = VotingControls()
        controls.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    var overflowMenuTap: (() -> Void)? = nil
    private var overflowMenuLayoutConstraints: [NSLayoutConstraint]?
    
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
        //when cell is being reused, must reset every property since cell isn't fully cleaned automatically
        media.sd_cancelCurrentImageLoad()
        media.image = UIImage(named:"squatLogoPlaceholder")!//nil
    }

    func addSubviews() {
        //contentView.addSubview(thumbnailImageView)
        contentView.addSubview(headerLabel)
        contentView.addSubview(subHeadLabel)
        contentView.addSubview(mediaContainerView)
        mediaContainerView.addSubview(media)
        mediaContainerView.addSubview(playButton)
        contentView.addSubview(supportingTextLabel)
        contentView.addSubview(votingControls)
        contentView.addSubview(overflowMenu)
    }
    
    func applyConstraints() {
        
        mediaHeightConstraint = mediaContainerView.heightAnchor.constraint(equalToConstant: CGFloat(0))
        NSLayoutConstraint.activate([
            
//        thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//        thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//        thumbnailImageView.widthAnchor.constraint(equalToConstant: 40),
//        thumbnailImageView.heightAnchor.constraint(equalToConstant: 40),

        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        subHeadLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
        subHeadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        mediaContainerView.topAnchor.constraint(equalTo: subHeadLabel.bottomAnchor, constant: 16),
        mediaContainerView.widthAnchor.constraint(equalToConstant: contentView.frame.width),
                
        media.centerXAnchor.constraint(equalTo: mediaContainerView.centerXAnchor),
        media.centerYAnchor.constraint(equalTo: mediaContainerView.centerYAnchor),
        media.widthAnchor.constraint(equalToConstant: contentView.frame.width),        
        
        playButton.centerXAnchor.constraint(equalTo: mediaContainerView.centerXAnchor),
        playButton.centerYAnchor.constraint(equalTo: mediaContainerView.centerYAnchor),
        playButton.widthAnchor.constraint(equalToConstant: 200),
        playButton.heightAnchor.constraint(equalToConstant: 200),
        
        supportingTextLabel.topAnchor.constraint(equalTo: mediaContainerView.bottomAnchor, constant: 16),
        supportingTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        supportingTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
        votingControls.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
        contentView.bottomAnchor.constraint(equalTo: votingControls.bottomAnchor, constant: 8)
        ])
    }
    
    func initControls() {
        overflowMenu.addTarget(self, action: #selector(overflowMenuOnTapped(_:)), for: .touchUpInside)
    }
    
    func setConstraintsWithMedia() {
        mediaHeightConstraint!.constant = CGFloat(FeedCell.IMAGE_HEIGHT)
        mediaHeightConstraint!.isActive = true
        mediaContainerView.isHidden = false
    }
    
    func setConstraintsWithNoMedia() {
        mediaHeightConstraint!.constant = 0
        mediaHeightConstraint!.isActive = true
        mediaContainerView.isHidden = true
        setVisibilityPlayButton(isVisible: false)
    }
    
    func setVisibilityPlayButton(isVisible: Bool) {
        playButton.isHidden = !isVisible
    }
    
    func setOverflowMenuLocation(location: OverflowMenuLocation) {
        if overflowMenuLayoutConstraints == nil {
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
    
    let mediaContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    let media: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
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
    
    let overflowMenu: MDCFlatButton = {
        let button = MDCFlatButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Images.moreHorizontal, for: .normal)
        button.tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onSurfaceColor
        return button
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let img = UIImage(systemName: "play.circle.fill")
        button.tintColor = UIColor.white
        button.setImage(img, for: .normal)
        return button
    }()
}
