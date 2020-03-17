import UIKit
import PromiseKit
import MaterialComponents

class ProfilePostCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePostedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var voteTotalLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var answersCountLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    var postId: String?
    var votingUserId: String?
    var voteDirection: VoteDirection?
    let upvoteColor = UIColor(red: 1.00, green: 0.16, blue: 0.00, alpha: 1.00)
    let downvoteColor = UIColor(red: 0.42, green: 0.57, blue: 1.00, alpha: 1.00)
    let neutralColor: UIColor = .white
    let moreIcon: UIImageView = {
        let icon = UIImageView()
        icon.isUserInteractionEnabled = true
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = Images.moreHorizontal
        return icon
    }()
    var onMoreIconClick: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyles()
        addSubviews()
        applyConstraints()
        addEvents()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func upvoteOnClick(_ sender: Any) {
        var currentVoteCount = Int(self.voteTotalLabel.text!)!
        if self.downvoteButton.tintColor == self.downvoteColor { // Going from downvote to upvote
            self.voteDirection = .Up
            currentVoteCount += 2
        }
        else if self.upvoteButton.tintColor == self.upvoteColor { // Already upvoted, removing upvote
            self.voteDirection = .Neutral
            currentVoteCount -= 1
        }
        else if self.upvoteButton.tintColor == self.neutralColor { // Upvoting for the first time
            self.voteDirection = .Up
            currentVoteCount += 1
        }
        
        toggleVotingControls()
        firstly {
            Services.exercisePostService.votePost(postId: postId!, userId: votingUserId!, direction: VoteDirection.Up)
        }.catch { error in
            //TODO: Show an error on screen
        }.finally {
            self.toggleVotingControls()
            self.adjustVotingControls()
            self.voteTotalLabel.text = "\(currentVoteCount)"
        }
    }
    
    @IBAction func downvoteOnClick(_ sender: Any) {
        var currentVoteCount = Int(self.voteTotalLabel.text!)!
        if self.upvoteButton.tintColor == self.upvoteColor { // Going from upvote to downvote
            self.voteDirection = .Down
            currentVoteCount -= 2
        }
        else if self.downvoteButton.tintColor == self.downvoteColor { // Already downvoted, removing downvote
            self.voteDirection = .Neutral
            currentVoteCount += 1
        }
        else if self.downvoteButton.tintColor == self.neutralColor { // Downvoting for the first time
            self.voteDirection = .Down
            currentVoteCount -= 1
        }
        
        toggleVotingControls()
        firstly {
            Services.exercisePostService.votePost(postId: postId!, userId: votingUserId!, direction: VoteDirection.Down)
        }.catch { error in
            //TODO: Show an error on screen
        }.finally {
            self.toggleVotingControls()
            self.adjustVotingControls()
            self.voteTotalLabel.text = "\(currentVoteCount)"
        }
    }
    
    func adjustVotingControls() {
        switch self.voteDirection {
        case .Up:
            self.upvoteButton.tintColor = self.upvoteColor
            self.voteTotalLabel.textColor = self.upvoteColor
            self.downvoteButton.tintColor = self.neutralColor
        case .Down:
            self.downvoteButton.tintColor = self.downvoteColor
            self.voteTotalLabel.textColor = self.downvoteColor
            self.upvoteButton.tintColor = self.neutralColor
        default:
            self.upvoteButton.tintColor = self.neutralColor
            self.downvoteButton.tintColor = self.neutralColor
            self.voteTotalLabel.textColor = self.neutralColor
            break
        }
    }
    private func toggleVotingControls() {
        self.upvoteButton.isEnabled = !self.upvoteButton.isEnabled
        self.downvoteButton.isEnabled = !self.downvoteButton.isEnabled
    }
    
    private func applyStyles() {
        self.titleLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.titleLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.datePostedLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle2
        self.datePostedLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.descriptionLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.descriptionLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.voteTotalLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.voteTotalLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.answersCountLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.answersCountLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.answersLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.answersLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.moreIcon.tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
    }
    
    private func applyConstraints() {
        moreIcon.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 12).isActive = true
        self.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.moreIcon.bottomAnchor, constant: 8).isActive = true
        self.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: moreIcon.trailingAnchor, constant: 12).isActive = true
    }
    
    private func addSubviews() {
        self.addSubview(self.moreIcon)
    }
    
    private func addEvents() {
        let moreIconTap = UITapGestureRecognizer(target: self, action: #selector(self.moreIconOnClick(sender:)))
        self.moreIcon.addGestureRecognizer(moreIconTap)
    }
    
    @objc func moreIconOnClick(sender: Any) {
        self.onMoreIconClick!()
    }
}
