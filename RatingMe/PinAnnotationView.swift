//
//  ParkAnnotationView.swift
//  JustParkTechnicalTest
//
//  Created by Riccardo Rizzo on 19/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotationView: MKAnnotationView,MKMapViewDelegate {
    
    enum JPSThumbnailAnnotationViewState {
        case JPSThumbnailAnnotationViewStateCollapsed
        case JPSThumbnailAnnotationViewStateExpanded
        case JPSThumbnailAnnotationViewStateAnimating
    }
    
    enum JPSThumbnailAnnotationViewAnimationDirection {
        case JPSThumbnailAnnotationViewAnimationDirectionGrow
        case JPSThumbnailAnnotationViewAnimationDirectionShrink
    }
    
    var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var imageView:UIImageView = UIImageView()
    var titleLabel:UILabel = UILabel()
    var subtitleLabel:UILabel = UILabel()
    var disclosureBlock: (() -> ())?
    var bgLayer:CAShapeLayer = CAShapeLayer()
    var disclosureButton:UIButton = UIButton()
    
    let kJPSThumbnailAnnotationViewReuseID = "JPSThumbnailAnnotationView";
    let kJPSThumbnailAnnotationViewStandardWidth:CGFloat     = 75.0;
    let kJPSThumbnailAnnotationViewStandardHeight:CGFloat    = 87.0;
    let kJPSThumbnailAnnotationViewExpandOffset      = 200.0;
    let kJPSThumbnailAnnotationViewVerticalOffset:CGFloat    = 34.0;
    let kJPSThumbnailAnnotationViewAnimationDuration = 0.25;
    
    var state: JPSThumbnailAnnotationViewState = JPSThumbnailAnnotationViewState.JPSThumbnailAnnotationViewStateCollapsed
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupImageView() {
        imageView = UIImageView(frame: CGRectMake(12.5, 12.5, 50.0, 47.0));
        imageView.layer.cornerRadius = 4.0;
        imageView.layer.masksToBounds = true;
        imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        imageView.layer.borderWidth = 0.5
        self.addSubview(imageView)
    }
    
    func setupTitleLabel() {
        titleLabel = UILabel(frame: CGRectMake(-32.0, 16.0, 168.0, 20.0))
        titleLabel.textColor = UIColor.darkTextColor()
        titleLabel.font = UIFont(name: "bold", size: 17)
        titleLabel.minimumScaleFactor = 0.8;
        titleLabel.adjustsFontSizeToFitWidth = true;
        self.addSubview(titleLabel)
    }
    
    func setupSubtitleLabel() {
        subtitleLabel = UILabel(frame: CGRectMake(-32.0, 36.0, 168.0, 20.0))
        subtitleLabel.textColor = UIColor.grayColor()
        subtitleLabel.font = UIFont(name: "system", size: 12)
        self.addSubview(subtitleLabel)
    }
    
    func setLayerProperties() {
        bgLayer = CAShapeLayer(layer: layer)
        let path:CGPathRef = newBubbleWithRect(self.bounds)
        bgLayer.path = path

        //CFRelease(path);
        bgLayer.fillColor = UIColor.whiteColor().CGColor
    
        bgLayer.shadowColor = UIColor.blackColor().CGColor
        bgLayer.shadowOffset = CGSizeMake(0.0, 3.0)
        bgLayer.shadowRadius = 2.0
        bgLayer.shadowOpacity = 0.5
    
        bgLayer.masksToBounds = false
        self.layer.insertSublayer(bgLayer, atIndex: 0)
    }
    
     func disclosureButtonImage() -> UIImage {
        let size:CGSize = CGSizeMake(21.0, 36.0);
        UIGraphicsBeginImageContextWithOptions(size, false,UIScreen.mainScreen().scale)
        let bezierPath:UIBezierPath = UIBezierPath() //[UIBezierPath bezierPath];
        bezierPath.moveToPoint(CGPointMake(2.0, 2.0))
        bezierPath.addLineToPoint(CGPointMake(10.0, 10.0))
        bezierPath.addLineToPoint(CGPointMake(2.0, 18.0))
        UIColor.lightGrayColor().setStroke()
        bezierPath.lineWidth = 3.0
        bezierPath.stroke()
    
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image;
    }
    
    func setupDisclosureButton() {
        let iOS7:Bool =  UIDevice.currentDevice().systemVersion.toDouble() >= 7.0
        let buttonType:UIButtonType = iOS7 ? UIButtonType.System : UIButtonType.Custom
        disclosureButton = UIButton.buttonWithType(buttonType) as! UIButton
        disclosureButton.tintColor = UIColor.grayColor()
        
        let disclosureIndicatorImage:UIImage = disclosureButtonImage()
        disclosureButton.setImage(disclosureIndicatorImage, forState: UIControlState.Normal)
        var xx:Double = kJPSThumbnailAnnotationViewExpandOffset/2.0
        xx = xx + Double(self.frame.size.width/2.0) + 8.0
        disclosureButton.frame = CGRectMake(CGFloat(xx), 26.5, disclosureIndicatorImage.size.width,disclosureIndicatorImage.size.height);
        
        disclosureButton.addTarget(self, action: "didTapDisclosureButton", forControlEvents: UIControlEvents.TouchDown)
        self.addSubview(disclosureButton)
    }
    
    func didTapDisclosureButton() {
        if ((self.disclosureBlock) != nil) {
            self.disclosureBlock!();
        }
    }
    
    func setDetailGroupAlpha(alpha:CGFloat) {
        self.disclosureButton.alpha = alpha;
        self.titleLabel.alpha = alpha;
        self.subtitleLabel.alpha = alpha;
    }
    
    func setupView() {
        setupImageView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupDisclosureButton()
        setLayerProperties()
        setDetailGroupAlpha(0.0)
    }
    
    func updateWithThumbnail(thumbnail:PinAnnotation) {
        self.coordinate = thumbnail.coordinate;
        self.titleLabel.text = thumbnail.title;
        self.subtitleLabel.text = thumbnail.subtitle;
        var image:UIImage = UIImage()
        
        if !thumbnail.isAdvertisement {
                switch(thumbnail.Rating)
                {
                    case "0":
                        image = UIImage(named: "baloon_no_star")!
                        break
                    case "1":
                        image = UIImage(named: "baloon_1_star")!
                        break
                    case "2":
                        image = UIImage(named: "baloon_2_star")!
                        break
                    case "3":
                        image = UIImage(named: "baloon_3_star")!
                        break
                    case "4":
                        image = UIImage(named: "baloon_4_star")!
                        break
                    case "5":
                        image = UIImage(named: "baloon_5_star")!
                        break
                    default:
                        image = UIImage(named: "baloon_no_star")!
                        break
                }
                self.imageView.image = image
        }
        else {
            if let checkedUrl = NSURL(string:thumbnail.advertisementImageLink) {

                downloadImage(checkedUrl,frame: self.imageView)
            }

        }
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func downloadImage(url:NSURL, frame:UIImageView){
        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
               // let img = self.imageResize(UIImage(data: data!)!, sizeChange: CGSizeMake(50, 47)) as! UIImage
                frame.image = UIImage(data: data!)
            }
        }
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    func didSelectAnnotationViewInMap(mapView:MKMapView) {
        mapView.setCenterCoordinate(self.coordinate, animated:true)
        expand()
    }
    
    func didDeselectAnnotationViewInMap(mapView:MKMapView) {
        shrink()
    }
    
    
    func expand() {
        
        if (self.state != JPSThumbnailAnnotationViewState.JPSThumbnailAnnotationViewStateCollapsed) {
            return
        }
    
        self.state = JPSThumbnailAnnotationViewState.JPSThumbnailAnnotationViewStateAnimating;
        animateBubbleWithDirection(.JPSThumbnailAnnotationViewAnimationDirectionGrow)
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGFloat(self.frame.size.width)+CGFloat(kJPSThumbnailAnnotationViewExpandOffset), self.frame.size.height)
        self.centerOffset = CGPointMake(CGFloat(kJPSThumbnailAnnotationViewExpandOffset/2.0), -kJPSThumbnailAnnotationViewVerticalOffset)
        
        UIView.animateWithDuration(kJPSThumbnailAnnotationViewAnimationDuration/2.0, delay: kJPSThumbnailAnnotationViewAnimationDuration, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.setDetailGroupAlpha(1.0)
        }, completion: { (complete) -> Void in
            self.state = JPSThumbnailAnnotationViewState.JPSThumbnailAnnotationViewStateExpanded;
        })
    }
    
    func shrink() {
        
        if (self.state != .JPSThumbnailAnnotationViewStateExpanded){
            return
        }
    
        self.state = .JPSThumbnailAnnotationViewStateAnimating;
    
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                CGFloat(self.frame.size.width - CGFloat(kJPSThumbnailAnnotationViewExpandOffset)),
                                self.frame.size.height)
    
        UIView.animateWithDuration(kJPSThumbnailAnnotationViewAnimationDuration/2.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.setDetailGroupAlpha(0.0)
        }) { (completion) -> Void in
                self.animateBubbleWithDirection(.JPSThumbnailAnnotationViewAnimationDirectionShrink)
                self.centerOffset = CGPointMake(0, -self.kJPSThumbnailAnnotationViewVerticalOffset)
            }

    }
    
    func animateBubbleWithDirection(animationDirection:JPSThumbnailAnnotationViewAnimationDirection) {
    
        let growing:Bool = (animationDirection == .JPSThumbnailAnnotationViewAnimationDirectionGrow)
    // Image
        UIView.animateWithDuration(kJPSThumbnailAnnotationViewAnimationDuration, animations: { () -> Void in
            let xOffset:CGFloat = (growing ? -1 : 1) * CGFloat(self.kJPSThumbnailAnnotationViewExpandOffset/2.0);
            self.imageView.frame = CGRectOffset(self.imageView.frame, xOffset, 0.0);
        }) { (finished) -> Void in
            if (animationDirection == .JPSThumbnailAnnotationViewAnimationDirectionShrink) {
                self.state = .JPSThumbnailAnnotationViewStateCollapsed;
            }
        }
    
    // Bubble
        let animation:CABasicAnimation =  CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.repeatCount = 1
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.duration = kJPSThumbnailAnnotationViewAnimationDuration
    
    // Stroke & Shadow From/To Values
        let largeRect:CGRect = CGRectInset(self.bounds, CGFloat(-kJPSThumbnailAnnotationViewExpandOffset/2.0), CGFloat(0.0))
        let fromPath:CGPathRef = newBubbleWithRect(growing ? self.bounds : largeRect)
        animation.fromValue = fromPath;
        let toPath:CGPathRef = newBubbleWithRect(growing ? largeRect : self.bounds)
        animation.toValue = toPath;
        self.bgLayer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        if annotation is PinAnnotation {
            let pinAnnotation = self.annotation as! PinAnnotation
            
            self.canShowCallout = false;
            self.frame = CGRectMake(0.0, 0.0, kJPSThumbnailAnnotationViewStandardWidth, kJPSThumbnailAnnotationViewStandardHeight)
        
            self.backgroundColor = UIColor.clearColor()
            self.centerOffset = CGPointMake(0, -kJPSThumbnailAnnotationViewVerticalOffset)
        
            state = JPSThumbnailAnnotationViewState.JPSThumbnailAnnotationViewStateCollapsed;
            setupView()
            updateWithThumbnail(pinAnnotation)
        }
    }
    
    func newBubbleWithRect(rect_in:CGRect) -> CGPathRef {
        let stroke:CGFloat = 1.0
        let radius:CGFloat  = 7.0
        let path:CGMutablePathRef = CGPathCreateMutable()
        let parentX:CGFloat = rect_in.origin.x + rect_in.size.width/2.0
    
        // Determine Size
        var rect:CGRect = CGRectMake(rect_in.origin.x+(stroke / 2.0 + 7.0), rect_in.origin.y+( stroke / 2.0 + 7.0), rect_in.size.width-(stroke + 14.0), rect_in.size.height-(stroke + 29.0))

    
        // Create Callout Bubble Path
        CGPathMoveToPoint(path, nil, rect.origin.x, rect.origin.y + radius);
        CGPathAddLineToPoint(path, nil, rect.origin.x, rect.origin.y + rect.size.height - radius);
        CGPathAddArc(path, nil, CGFloat(rect.origin.x+radius), CGFloat(rect.origin.y+rect.size.height-radius), radius, CGFloat(M_PI), CGFloat(M_PI_2), true)
        CGPathAddLineToPoint(path, nil, parentX - 14.0, rect.origin.y + rect.size.height);
        CGPathAddLineToPoint(path, nil, parentX, rect.origin.y + rect.size.height + 14.0);
        CGPathAddLineToPoint(path, nil, parentX + 14.0, rect.origin.y + rect.size.height);
        CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
        CGPathAddArc(path, nil, CGFloat(rect.origin.x + rect.size.width - radius), CGFloat(rect.origin.y + rect.size.height - radius), radius, CGFloat(M_PI_2), 0.0, true);
        CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, rect.origin.y + radius);
        CGPathAddArc(path, nil, CGFloat(rect.origin.x + rect.size.width - radius), CGFloat(rect.origin.y + radius), radius, 0.0, CGFloat(-M_PI_2), true);
        CGPathAddLineToPoint(path, nil, rect.origin.x + radius, rect.origin.y);
        CGPathAddArc(path, nil, CGFloat(rect.origin.x + radius), CGFloat(rect.origin.y + radius), CGFloat(radius), CGFloat(-M_PI_2), CGFloat(M_PI), true);
        CGPathCloseSubpath(path);
        return path;
    }

}
