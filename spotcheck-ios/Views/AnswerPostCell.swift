import UIKit

class AnswerPostCell: UITableViewCell {
    @IBOutlet weak var answererNameLabel: UILabel!
    @IBOutlet weak var answerBodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
