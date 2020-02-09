//
//  PostCell.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 2/9/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorTaglineLabel: UILabel!
    
    @IBOutlet weak var upvoteBtn: UIImageView!
    @IBOutlet weak var upvoteCounts: UILabel!
    
    
    @IBOutlet weak var answersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
