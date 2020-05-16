//
//  DetailedPostCell.swift
//  spotcheck-ios
//
//  Created by Miguel Paysan on 2/19/20.
//  Copyright © 2020 Miguel Paysan. All rights reserved.
//

import UIKit

class DetailedPostCell: UITableViewCell {
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var posterDetailLabel: UILabel!
    @IBOutlet weak var postBodyLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
