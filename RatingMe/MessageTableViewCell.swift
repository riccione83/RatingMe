//
//  MessageTableViewCell.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 14/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SWTableViewCell

class MessageTableViewCell: SWTableViewCell {

    @IBOutlet var unreadedIcon: UIView!
    @IBOutlet var messageText: UILabel!
    var messageID: String!
    @IBOutlet var longMessageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
