//
//  CustomImageView.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 12/11/15.
//  Copyright © 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(self.progressIndicatorView)
        progressIndicatorView.frame = bounds
        progressIndicatorView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
    }
    
     func updateProgress(receivedSize:CGFloat, expectedSize:CGFloat) {
        self.progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(expectedSize)
    }
    
    func revealImage() {
        self.progressIndicatorView.reveal()
    }

}
