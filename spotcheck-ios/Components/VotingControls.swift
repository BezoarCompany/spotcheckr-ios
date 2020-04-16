import MaterialComponents
import PromiseKit

class VotingControls: UIView {
    var votingUserId: String?
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
        upvoteButton.addTarget(self, action: #selector(upvoteOnClick(_:)), for: .touchUpInside)
        downvoteButton.addTarget(self, action: #selector(downvoteOnClick(_:)), for: .touchUpInside)
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
        if self.downvoteButton.tintColor == self.downvoteColor || self.upvoteButton.tintColor == self.neutralColor { // Going from downvote to upvote or upvoting for the first time
            self.voteDirection = .Up
        }
        else if self.upvoteButton.tintColor == self.upvoteColor { // Already upvoted, removing upvote
            self.voteDirection = .Neutral
        }
        
        self.renderVotingControls()
        
        firstly {
            self.upvoteOnTap!(self.voteDirection!)
        }.catch { error in
            //Do nothing
        }
    }
    
    @objc func downvoteOnClick(_ sender: Any) {
        if self.upvoteButton.tintColor == self.upvoteColor || self.downvoteButton.tintColor == self.neutralColor { // Going from upvote to downvote or downvoting for the first time
            self.voteDirection = .Down
        }
        else if self.downvoteButton.tintColor == self.downvoteColor { // Already downvoted, removing downvote
            self.voteDirection = .Neutral
        }
        
        self.renderVotingControls()
        
        firstly {
            self.downvoteOnTap!(self.voteDirection!)
        }.catch { error in
            //Ignore voting errors
        }
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
