//
//  NewMailView.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 24/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit

class NewMailView: UIView {    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        MailCanvasStyleKit.drawMail()
    }


}
