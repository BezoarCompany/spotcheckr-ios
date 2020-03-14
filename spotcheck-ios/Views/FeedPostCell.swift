import UIKit

class FeedPostCell: UITableViewCell {
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postBodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyStyles()
    }

    private func applyStyles() {
        postLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.headline6
        postLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        postBodyLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        //tableview separator
        let mScreenSize = UIScreen.main.bounds
        let mSeparatorHeight = CGFloat(4.0)
        let mAddSeparator = UIView.init(frame: CGRect(x: 0, y: 0, width: mScreenSize.width, height: mSeparatorHeight))
        mAddSeparator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.33)
        self.addSubview(mAddSeparator)
                
        /*
        authorNameLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle2
        authorNameLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        upvoteCounts.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle1
        upvoteCounts.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        answersLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle1
        answersLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
 */
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        //when cell is being reused, must reset every property since cell isn't fully cleaned automatically
        photoView.sd_cancelCurrentImageLoad()
        photoView.image = UIImage(named:"squat1")!//nil
    }

}
