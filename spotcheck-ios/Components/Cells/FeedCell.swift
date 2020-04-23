import MaterialComponents
import PromiseKit
import AVKit

enum OverflowMenuLocation {
    case top, bottom
}

class FeedCell: CardCollectionCell {
    static let IMAGE_HEIGHT = 300
    
    var postDetailClosure:  (() -> Void)? = nil
    var avPlayerViewController = AVPlayerViewController()
    
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
        initPostDetailActions()
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
        avPlayerViewController.removeFromParent()
    }
    
    @objc func toPostDetailOnClick(_ sender: Any) {
        if let postDetailClosure = postDetailClosure {
            postDetailClosure()
        }
    }

    func applyConstraints() {
        mediaHeightConstraint = mediaContainerView.heightAnchor.constraint(equalToConstant: CGFloat(0))
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
        
        mediaContainerView.topAnchor.constraint(equalTo: subHeadLabel.bottomAnchor, constant: 16),
        mediaContainerView.widthAnchor.constraint(equalToConstant: contentView.frame.width),
                
        media.centerXAnchor.constraint(equalTo: mediaContainerView.centerXAnchor),
        media.centerYAnchor.constraint(equalTo: mediaContainerView.centerYAnchor),
        media.widthAnchor.constraint(equalToConstant: contentView.frame.width),
        
        supportingTextLabel.topAnchor.constraint(equalTo: mediaContainerView.bottomAnchor, constant: 16),
        supportingTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        supportingTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
        votingControls.topAnchor.constraint(equalTo: supportingTextLabel.bottomAnchor, constant: 4),
        dividerLeadingConstraint!,
        cellDivider.topAnchor.constraint(equalTo: votingControls.bottomAnchor, constant: 4),
        contentView.trailingAnchor.constraint(equalTo: cellDivider.trailingAnchor),
        contentView.bottomAnchor.constraint(equalTo: cellDivider.bottomAnchor)
        ])
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
    }
    
    func initPostDetailActions() {
        //Tap Gesture Recognizer is only referenced by last UIElement to Add it.
        //Although they share the same action selector, we must create a gesture for each UI element to use
        let tap = UITapGestureRecognizer(target: self, action: #selector(toPostDetailOnClick(_:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(toPostDetailOnClick(_:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(toPostDetailOnClick(_:)))

        headerLabel.isUserInteractionEnabled = true
        subHeadLabel.isUserInteractionEnabled = true
        supportingTextLabel.isUserInteractionEnabled = true

        headerLabel.addGestureRecognizer(tap)
        subHeadLabel.addGestureRecognizer(tap2)
        supportingTextLabel.addGestureRecognizer(tap3)
    }
    
    func initVideoPlayer(videoFileName: String) {
      
      firstly {
          Services.storageService.getVideoDownloadURL(filename: videoFileName)
      }.done { url in

          let player = AVPlayer(url: url)
          self.avPlayerViewController = AVPlayerViewController()
          self.avPlayerViewController.player = player
          self.avPlayerViewController.view.frame = self.mediaContainerView.bounds
          
          self.mediaContainerView.addSubview(self.avPlayerViewController.view)
          
      }
    }
}
