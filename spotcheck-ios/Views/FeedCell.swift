import MaterialComponents
import PromiseKit

class FeedCell: MDCCardCollectionCell {
    static let cellId = "FeedCell"
    static let IMAGE_HEIGHT = 200
    
    lazy var widthConstraint: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()    
        
    typealias UpdateVoteClosureType = ((_ post:ExercisePost) -> Void)
    
    var postId: String?
    var votingUserId: String?
    var voteDirection: VoteDirection?
    let upvoteColor = Colors.upvote
    let downvoteColor = Colors.downvote
    let neutralColor: UIColor = Colors.neutralVote
    var mediaHeightConstraint: NSLayoutConstraint?
    var post: ExercisePost?
    var updateVoteClosure: UpdateVoteClosureType?
    
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
        contentView.addSubview(media)
        contentView.addSubview(supportingTextLabel)
        contentView.addSubview(upvoteButton)
        contentView.addSubview(downvoteButton)
    }
    
    func applyConstraints() {
        
        mediaHeightConstraint = media.heightAnchor.constraint(equalToConstant: CGFloat(0))
        
        NSLayoutConstraint.activate([
            
//        thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//        thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//        thumbnailImageView.widthAnchor.constraint(equalToConstant: 40),
//        thumbnailImageView.heightAnchor.constraint(equalToConstant: 40),

        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        subHeadLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
        subHeadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        
        media.topAnchor.constraint(equalTo: subHeadLabel.bottomAnchor, constant: 16),
        media.widthAnchor.constraint(equalToConstant: contentView.frame.width),
        
        supportingTextLabel.topAnchor.constraint(equalTo: media.bottomAnchor, constant: 16),
        supportingTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        supportingTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
        upvoteButton.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
        upvoteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
        
        downvoteButton.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
        downvoteButton.leadingAnchor.constraint(equalTo: upvoteButton.trailingAnchor, constant: 8),
        
        contentView.bottomAnchor.constraint(equalTo: upvoteButton.bottomAnchor, constant: 16)
        ])
    }
    
    func initControls() {
        upvoteButton.addTarget(self, action: #selector(upvoteOnClick(_:)), for: .touchUpInside)
        downvoteButton.addTarget(self, action: #selector(downvoteOnClick(_:)), for: .touchUpInside)
    }
    
    @objc func upvoteOnClick(_ sender: Any) {
        if self.downvoteButton.tintColor == self.downvoteColor { // Going from downvote to upvote
            self.voteDirection = .Up
        }
        else if self.upvoteButton.tintColor == self.upvoteColor { // Already upvoted, removing upvote
            self.voteDirection = .Neutral
        }
        else if self.upvoteButton.tintColor == self.neutralColor { // Upvoting for the first time
            self.voteDirection = .Up
        }
        
        if let post = self.post, let updateVoteClosure = self.updateVoteClosure {
            post.metrics.currentVoteDirection = self.voteDirection!
            updateVoteClosure(post)
        }
        
        firstly {
            Services.exercisePostService.votePost(postId: postId!, userId: votingUserId!, direction: VoteDirection.Up)
        }.catch { error in
            //Ignore errors for voting.
        }

        self.renderVotingControls()
    }
    
    @objc func downvoteOnClick(_ sender: Any) {
        if self.upvoteButton.tintColor == self.upvoteColor { // Going from upvote to downvote
            self.voteDirection = .Down
        }
        else if self.downvoteButton.tintColor == self.downvoteColor { // Already downvoted, removing downvote
            self.voteDirection = .Neutral
        }
        else if self.downvoteButton.tintColor == self.neutralColor { // Downvoting for the first time
            self.voteDirection = .Down
        }
        
        if let post = self.post, let updateVoteClosure = self.updateVoteClosure {            
            post.metrics.currentVoteDirection = self.voteDirection!
            updateVoteClosure(post)
        }
        
        firstly {
            Services.exercisePostService.votePost(postId: postId!, userId: votingUserId!, direction: VoteDirection.Down)
        }.catch { error in
            //Ignore voting errors
        }
        
        self.renderVotingControls()
    }
    
    func renderVotingControls() {
        switch self.voteDirection {
        case .Up:
            self.upvoteButton.tintColor = self.upvoteColor
            self.downvoteButton.tintColor = self.neutralColor
        case .Down:
            self.downvoteButton.tintColor = self.downvoteColor
            self.upvoteButton.tintColor = self.neutralColor
        default:
            self.upvoteButton.tintColor = self.neutralColor
            self.downvoteButton.tintColor = self.neutralColor
            break
        }
    }
    
    
    func setConstraintsWithMedia() {
        mediaHeightConstraint!.constant = CGFloat(FeedCell.IMAGE_HEIGHT)
        mediaHeightConstraint!.isActive = true
        media.isHidden = false
    }
    
    func setConstraintsWithNoMedia() {
        mediaHeightConstraint!.constant = 0
        mediaHeightConstraint!.isActive = true
        media.isHidden = true
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
