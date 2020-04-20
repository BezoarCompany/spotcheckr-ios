import MaterialComponents
import PromiseKit

enum OverflowMenuLocation {
    case top, bottom
}

class FeedCell: CardCollectionCell {
    static let IMAGE_HEIGHT = 200
    
    lazy var widthConstraint: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()    
    
    var postId: ExercisePostID?
    var mediaHeightConstraint: NSLayoutConstraint?
    var post: ExercisePost?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyConstraints()
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

    func applyConstraints() {
        mediaHeightConstraint = media.heightAnchor.constraint(equalToConstant: CGFloat(0))
        dividerLeadingConstraint = cellDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        
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
        
        votingControls.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 24),
        dividerLeadingConstraint!,
        cellDivider.topAnchor.constraint(equalTo: votingControls.bottomAnchor, constant: 8),
        contentView.trailingAnchor.constraint(equalTo: cellDivider.trailingAnchor),
        contentView.bottomAnchor.constraint(equalTo: cellDivider.bottomAnchor)
        ])
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
}
