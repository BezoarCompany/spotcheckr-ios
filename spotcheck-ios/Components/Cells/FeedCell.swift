import MaterialComponents
import PromiseKit
import AVKit

enum OverflowMenuLocation {
    case top, bottom
}

class FeedCell: CardCollectionCell {
    static let imageHeight = 300

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
        media.image = UIImage(named: "squatLogoPlaceholder")!//nil
        avPlayerViewController.removeFromParent()
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
        headerLabel.widthAnchor.constraint(equalToConstant: 312),
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
        mediaHeightConstraint!.constant = CGFloat(FeedCell.imageHeight)
        mediaHeightConstraint!.isActive = true
        mediaContainerView.isHidden = false
    }

    func setConstraintsWithNoMedia() {
        mediaHeightConstraint!.constant = 0
        mediaHeightConstraint!.isActive = true
        mediaContainerView.isHidden = true
    }

    func initVideoPlayer(videoFileName: String) {

      firstly {
          Services.storageService.getVideoDownloadURL(filename: videoFileName)
      }.done { url in

          let player = AVPlayer(url: url)
          self.avPlayerViewController = AVPlayerViewController()
          self.avPlayerViewController.player = player
          self.avPlayerViewController.view.frame = self.mediaContainerView.bounds
          self.avPlayerViewController.entersFullScreenWhenPlaybackBegins = true // TODO: Does not seem to actually go full screen, neither does presenting it via rootViewController
          self.avPlayerViewController.exitsFullScreenWhenPlaybackEnds = true
          //self.avPlayerViewController.videoGravity = AVLayerVideoGravity.resize
          self.mediaContainerView.addSubview(self.avPlayerViewController.view)

      }
    }
}
