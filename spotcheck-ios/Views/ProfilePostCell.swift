import UIKit
import PromiseKit
import MaterialComponents

class ProfilePostCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePostedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var answersIcon: UIImageView!
    @IBOutlet weak var answersCountLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!

    var postId: ExercisePostID?
    var votingUserId: UserID?
    var voteDirection: VoteDirection?
    var upvoteOnTap: ((_ voteDirection: VoteDirection) -> Promise<Void>)?
    var downvoteOnTap: ((_ voteDirection: VoteDirection) -> Promise<Void>)?
    let upvoteColor = Colors.upvote
    let downvoteColor = Colors.downvote
    let neutralColor: UIColor = Colors.neutralVote
    let moreIcon: UIImageView = {
        let icon = UIImageView()
        icon.isUserInteractionEnabled = true
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = Images.moreHorizontal
        return icon
    }()
    var onMoreIconClick: (() -> Void)?
    var hideAnswers = false

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyles()
        addSubviews()
        applyConstraints()
        addEvents()
        toggleControls()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func upvoteOnClick(_ sender: Any) {
        if self.downvoteButton.tintColor == self.downvoteColor { // Going from downvote to upvote
            self.voteDirection = .up
        } else if self.upvoteButton.tintColor == self.upvoteColor { // Already upvoted, removing upvote
            self.voteDirection = .neutral
        } else if self.upvoteButton.tintColor == self.neutralColor { // Upvoting for the first time
            self.voteDirection = .up
        }
        self.adjustVotingControls()
        firstly {
            self.upvoteOnTap!(self.voteDirection!)
        }.catch { _ in
            //TODO: Show an error on screen
        }
    }

    @IBAction func downvoteOnClick(_ sender: Any) {
        if self.upvoteButton.tintColor == self.upvoteColor { // Going from upvote to downvote
            self.voteDirection = .down
        } else if self.downvoteButton.tintColor == self.downvoteColor { // Already downvoted, removing downvote
            self.voteDirection = .neutral
        } else if self.downvoteButton.tintColor == self.neutralColor { // Downvoting for the first time
            self.voteDirection = .down
        }
        self.adjustVotingControls()

        firstly {
            self.downvoteOnTap!(self.voteDirection!)
        }.catch { _ in
            //TODO: Show an error on screen
        }
    }

    func adjustVotingControls() {
        switch self.voteDirection {
        case .up:
            self.upvoteButton.tintColor = self.upvoteColor
            self.downvoteButton.tintColor = self.neutralColor
        case .down:
            self.downvoteButton.tintColor = self.downvoteColor
            self.upvoteButton.tintColor = self.neutralColor
        default:
            self.upvoteButton.tintColor = self.neutralColor
            self.downvoteButton.tintColor = self.neutralColor
            break
        }
    }

    private func applyStyles() {
        self.titleLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.titleLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.datePostedLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle2
        self.datePostedLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.descriptionLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.descriptionLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.answersCountLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.answersCountLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.answersLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        self.answersLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.moreIcon.tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
    }

    private func applyConstraints() {
        moreIcon.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 46).isActive = true
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

    private func toggleControls() {
        if self.hideAnswers {
            self.answersIcon.isHidden = true
            self.answersLabel.isHidden = true
            self.answersCountLabel.isHidden = true
        }
    }
}
