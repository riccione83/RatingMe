//
//  RateCustomCell.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 24/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class RateCustomCell: UITableViewCell {
    
    @IBOutlet var lblQuestion1: UILabel!
    @IBOutlet var lblQuestion2: UILabel!
    @IBOutlet var lblQuestion3: UILabel!
    
    @IBOutlet var progressQuestion1: UIProgressView!
    @IBOutlet var progressQuestion2: UIProgressView!
    @IBOutlet var progressQuesiton3: UIProgressView!
    
    @IBOutlet var labelNote: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
