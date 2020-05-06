import MaterialComponents
import PromiseKit

class VotingControls: UIView {
    var votingUserId: UserID?
    var voteDirection: VoteDirection?
    var upvoteOnTap: ((_ voteDirection: VoteDirection) -> Promise<Void>)?
    var downvoteOnTap: ((_ voteDirection: VoteDirection) -> Promise<Void>)?
    let upvoteColor = Colors.upvote
    let downvoteColor = Colors.downvote
    let neutralColor: UIColor = Colors.neutralVote

    override class var requiresConstraintBasedLayout: Bool {
      return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        upvoteButton.view.addTarget(self, action: #selector(upvoteOnClick(_:)), for: .touchUpInside)
        downvoteButton.view.addTarget(self, action: #selector(downvoteOnClick(_:)), for: .touchUpInside)

        addSubview(upvoteButton)
        addSubview(downvoteButton)
        NSLayoutConstraint.activate([
            upvoteButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            downvoteButton.leadingAnchor.constraint(equalTo: upvoteButton.trailingAnchor),
            trailingAnchor.constraint(equalTo: downvoteButton.trailingAnchor),
            upvoteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            downvoteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            bottomAnchor.constraint(equalTo: upvoteButton.bottomAnchor),
            bottomAnchor.constraint(equalTo: downvoteButton.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func upvoteOnClick(_ sender: Any) {
        let isDownvoteToUpvote = { return self.downvoteButton.view.imageTintColor(for: .normal) == self.downvoteColor }
        let isInitialUpvote = { return self.upvoteButton.view.imageTintColor(for: .normal) == self.neutralColor }
        let isRemovingUpvote = { return self.upvoteButton.view.imageTintColor(for: .normal) == self.upvoteColor }

        if isDownvoteToUpvote() || isInitialUpvote() {
            voteDirection = .up
        } else if isRemovingUpvote() { // Already upvoted, removing upvote
            voteDirection = .neutral
        }

        renderVotingControls()

        firstly {
            upvoteOnTap!(voteDirection!)
        }.catch { _ in
            //Do nothing
        }
    }

    @objc func downvoteOnClick(_ sender: Any) {
        let isUpvoteToDownvote = { return self.upvoteButton.view.imageTintColor(for: .normal) == self.upvoteColor }
        let isInitialDownvote = { return self.downvoteButton.view.imageTintColor(for: .normal) == self.neutralColor }
        let isRemovingDownvote = { return self.downvoteButton.view.imageTintColor(for: .normal) == self.downvoteColor }

        if isUpvoteToDownvote() || isInitialDownvote() {
            voteDirection = .down
        } else if isRemovingDownvote() {
            voteDirection = .neutral
        }

        renderVotingControls()

        firstly {
            downvoteOnTap!(voteDirection!)
        }.catch { _ in
            //Ignore voting errors
        }
    }

    func renderVotingControls() {
        switch voteDirection {
        case .up:
            downvoteButton.view.setImageTintColor(neutralColor, for: .normal)
            upvoteButton.view.setImageTintColor(upvoteColor, for: .normal)
        case .down:
            downvoteButton.view.setImageTintColor(downvoteColor, for: .normal)
            upvoteButton.view.setImageTintColor(neutralColor, for: .normal)
        default:
            downvoteButton.view.setImageTintColor(neutralColor, for: .normal)
            upvoteButton.view.setImageTintColor(neutralColor, for: .normal)
            break
        }
    }

    let upvoteButton: FlatButton = {
        let button = FlatButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.view.setImage(Images.arrowUp, for: .normal)
        return button
    }()

    let downvoteButton: FlatButton = {
        let button = FlatButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.view.setImage(Images.arrowDown, for: .normal)
        return button
    }()
}
