import MaterialComponents
import PromiseKit

class LoadingCell: MDCCardCollectionCell {
    static let cellId = "LoadingCell"
    
    var widthConstraint: NSLayoutConstraint?
    var supportingTextTopConstraint: NSLayoutConstraint?
    var postId: String?
    var votingUserId: String?
    var voteDirection: VoteDirection?
    let upvoteColor = Colors.upvote
    let downvoteColor = Colors.downvote
    let neutralColor: UIColor = Colors.neutralVote
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)
        applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellWidth(width: CGFloat) {
        widthConstraint?.constant = width
        widthConstraint?.isActive = true
    }
   
}
