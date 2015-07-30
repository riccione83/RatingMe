//
//  StarRating.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 02/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class StarRating: UIView {
    
    var currentRating = 0
    var starRating:NSMutableArray = NSMutableArray.new()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init() {
        super.init(frame: CGRectMake(0, 0, 220, 52))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    func initUI(rating: Int) {
        self.backgroundColor = UIColor.clearColor() //UIColor.blueColor()
        self.userInteractionEnabled = true
        self.layer.cornerRadius = 10
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        currentRating = rating
        for var i=0; i<5; i++ {
            let imageView:UIImageView = UIImageView(image: UIImage(named: "deselect_star"))
            let imageFrame = CGRectMake(CGFloat(i*45), 1, 40, 40)
            imageView.frame = imageFrame
            imageView.tag = i+300
            starRating.addObject(imageView)
            self.addSubview(imageView)
        }
        refreshStars(false)
    }
    
    func refreshStars(animate:Bool) {
        for var i=0; i < starRating.count; i++ {
            let imageView:UIImageView = starRating.objectAtIndex(i) as! UIImageView
            if (currentRating >= i+1) {
                imageView.image = UIImage(named: "selected_star")
                
                if(animate) {
                    let currentTransform: CGAffineTransform = imageView.transform
                    let newTransform:CGAffineTransform = CGAffineTransformScale(currentTransform, 0, 0)
                    imageView.transform = newTransform
                    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 15, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                    imageView.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: nil)
                }
            }
            else if( currentRating > i) {
                imageView.image = UIImage(named: "deselect_star")
            }
            else {
                imageView.image = UIImage(named: "deselect_star")
            }
        }
    }
    
    func setRating(rating: Int) {
        currentRating = rating
        refreshStars(true)
    }

    func handleTouchAtLocation(touchLocation:CGPoint, animate:Bool) {
        for var i=4; i>=0; i-- {
            let imageView:UIImageView = starRating.objectAtIndex(i) as! UIImageView
            if( touchLocation.x > imageView.frame.origin.x) {
                currentRating = i+1
                break
            }
            else if( i == 0) {
                if (touchLocation.x <= imageView.frame.origin.x) {
                    currentRating = 0
                }
            }
        }
        refreshStars(animate)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch:UITouch = touches.first as! UITouch
        let touchLocation:CGPoint = touch.locationInView(self)
        handleTouchAtLocation(touchLocation,animate:false)

    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch:UITouch = touches.first as! UITouch
        let touchLocation:CGPoint = touch.locationInView(self)
        handleTouchAtLocation(touchLocation,animate:false)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch:UITouch = touches.first as! UITouch
        let touchLocation:CGPoint = touch.locationInView(self)
        handleTouchAtLocation(touchLocation,animate:true)
    }

}

