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
    
    @IBOutlet var labelNote: UILabel!
    @IBOutlet var labelNoteTitle: UILabel!
    
    @IBOutlet var starRatingQuestion1: StarRating!
    @IBOutlet var starRatingQuestion2: StarRating!
    @IBOutlet var starRatingQuestion3: StarRating!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.starRatingQuestion1.initUI(0, spacing: 22, imageSize: 20, withOpacity: false)
        self.starRatingQuestion2.initUI(0, spacing: 22, imageSize: 20, withOpacity: false)
        self.starRatingQuestion3.initUI(0, spacing: 22, imageSize: 20, withOpacity: false)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
