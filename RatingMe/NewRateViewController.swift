//
//  RateViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 02/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol RateControllerProtocol {
    func searchByUserLocation(lat:Double,lon:Double, center: Bool)
}

class RateViewController: UIViewController {
    
    var delegate:RateControllerProtocol? = nil
    let jsonRequest = JSonHelper()
    
    var isFullscreen = false
    var oldFrame: CGRect = CGRectMake(0, 0, 0, 0)
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var textDescription: UITextView!
    @IBOutlet var thumbImage: UIImageView!
    @IBOutlet var starRatingView1: StarRating!
    @IBOutlet var starRatingView2: StarRating!
    @IBOutlet var starRatingView3: StarRating!
    @IBOutlet var labelQuestion1: UILabel!
    @IBOutlet var labelQuestion2: UILabel!
    @IBOutlet var labelQuestion3: UILabel!
    @IBOutlet var txtRateDescription: UITextField!
    @IBOutlet var darkBackGroundView: UIView!
    
    var userInfos:User?
    var currentTitle:String = ""
    var currentDescription:String = ""
    var imageLink:UIImage?
    var currentRating:Double = 0
    var currentReviewID:String = ""
    var lastLatitude:Double = 0.0;
    var lastLongitude:Double = 0.0;
    var incrementValue = 0
    var Q1:String = ""
    var Q2:String = ""
    var Q3:String = ""
    
    @IBAction func feedbackClick(sender: AnyObject) {
        
        if !isFullscreen {
            
            if (txtRateDescription.text != "") {
                var rating = Int(currentRating)
            
                var divisor = 1
            
                if starRatingView2 != nil && !starRatingView2.hidden {
                    divisor += 1
                }
            
                if starRatingView3 != nil && !starRatingView3.hidden {
                    divisor += 1
                }
            
                rating = (starRatingView1.currentRating + starRatingView2.currentRating + starRatingView3.currentRating) / divisor
            
                newRating(currentReviewID, user_id: userInfos!.userID,user_name: userInfos!.userName, rate: Double(rating), description: txtRateDescription.text!, rate_q1: starRatingView1.currentRating,rate_q2: starRatingView2.currentRating, rate_q3: starRatingView3.currentRating)
            }
            else {
                showMessage("Please add a short note to send a new rating. Thankyou.")
            }
        }
        else {
            self.thumbImage.frame = self.oldFrame
            self.darkBackGroundView.alpha = 0.0
            self.darkBackGroundView.hidden = true
            self.textDescription.layer.cornerRadius = 0
            self.textDescription.backgroundColor = UIColor.clearColor()
            self.textDescription.alpha = 1
            self.starRatingView1.alpha = 1
            self.starRatingView2.alpha = 1
            self.starRatingView3.alpha = 1
            self.txtRateDescription.alpha = 1
            self.thumbImage.contentMode = UIViewContentMode.ScaleAspectFill
            self.thumbImage.layer.borderColor = UIColor(red: 13/255, green: 70/255, blue: 131/255, alpha: 1.0).CGColor
            self.isFullscreen = false
        }
    }
    
    @IBAction func returnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newRating(review_id:String, user_id:String,user_name:String, rate:Double, description:String, rate_q1:Int, rate_q2:Int, rate_q3:Int) {
    
        let params = ["review_id":review_id,
                      "user_id":user_id,
                      "description":description,
                      "rate_question1":rate_q1,
                      "rate_question2":rate_q2,
                      "rate_question3":rate_q3
                     ]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_newRating, parameters: params as! [String : AnyObject]) { (jsonData) -> () in
                if jsonData == nil {
                    return
                }
                let json = JSON(jsonData!)
            
                if let message = json["error"].string {
                    print(message)
                    self.showMessage(message)
                    return
                }

            if let message = json["message"].string {
                if (message == "success") {
                    NSLog("\(jsonData)")
                    self.delegate?.searchByUserLocation(self.lastLatitude, lon: self.lastLongitude, center: true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    func showMessage(message:String) {
        let popup:UIAlertController = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Create and add the OK action
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        popup.addAction(okAction)
        
        self.presentViewController(popup, animated: true, completion: nil)
    }
    
    func analyzeImageLink(link:String, increment:Int) {
        var linkArr = link.characters.split {$0 == "&"}.map { String($0) }
        var temp = linkArr[3].characters.split {$0 == "="}.map { String($0) }
        let currHeading = temp[1]
        var new_Link:String = ""
        var i = 0

        if (incrementValue == 0) {
            incrementValue = Int(currHeading)! + increment
        }
        else {
            incrementValue = incrementValue + increment
        }
        
        //Rebuild the string
        for itm in linkArr {
            if( i != 3) {
                new_Link += itm + "&"
            }
            else {
                new_Link += temp[0] + "=\(incrementValue)&"
            }
            i += 1
        }
        NSLog("\(new_Link)")
        
        if let checkedUrl = NSURL(string:jsonRequest.url + new_Link) {
            downloadImage(checkedUrl,frame: thumbImage)
        }
    }
    
    func swipeImage(sender: UISwipeGestureRecognizer) {
        
        if (sender.direction == UISwipeGestureRecognizerDirection.Left) {
            NSLog("Swipe to left")
       //     analyzeImageLink(imageLink, increment: 45)
        }
        else if (sender.direction == UISwipeGestureRecognizerDirection.Right) {
                NSLog("Swipe to right")
         //       analyzeImageLink(imageLink,increment: -45)
        }
    }
    
    func selectThumb(sender: UITapGestureRecognizer) {
        
        
        if (!isFullscreen) {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                
                self.darkBackGroundView.alpha = 1.0
                self.darkBackGroundView.hidden = false
                self.thumbImage.layer.borderColor = UIColor(red: 13/255, green: 70/255, blue: 131/255, alpha: 0.0).CGColor
                self.oldFrame = self.thumbImage.frame
                self.thumbImage.frame = self.view.frame
                self.thumbImage.contentMode = UIViewContentMode.ScaleAspectFit
                self.textDescription.backgroundColor = UIColor.whiteColor()
                self.textDescription.alpha = 0.0
                self.starRatingView1.alpha = 0.0
                self.starRatingView2.alpha = 0.0
                self.starRatingView3.alpha = 0.0
                self.txtRateDescription.alpha = 0.0
                }, completion: { (finished) -> Void in
                     self.isFullscreen = true
            })
        }
        else {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.thumbImage.frame = self.oldFrame
                self.darkBackGroundView.alpha = 0.0
                self.darkBackGroundView.hidden = true
                self.textDescription.layer.cornerRadius = 0
                self.textDescription.backgroundColor = UIColor.clearColor()
                self.textDescription.alpha = 1
                self.starRatingView1.alpha = 1
                self.starRatingView2.alpha = 1
                self.starRatingView3.alpha = 1
                self.txtRateDescription.alpha = 1

                }, completion: { (finished) -> Void in
                    self.thumbImage.contentMode = UIViewContentMode.ScaleAspectFill
                    self.thumbImage.layer.borderColor = UIColor(red: 13/255, green: 70/255, blue: 131/255, alpha: 1.0).CGColor
                    self.isFullscreen = false
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
      txtRateDescription.resignFirstResponder()
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    func closeKeyboard(touch:UIGestureRecognizer) {
        txtRateDescription.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(sender: NSNotification) {
    //    self.view.frame.origin.y -= 150
    }
    
    func keyboardWillHide(sender: NSNotification) {
    //    self.view.frame.origin.y += 150
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RateViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RateViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        
        let tapSelect:UITapGestureRecognizer = UITapGestureRecognizer()
        tapSelect.addTarget(self, action: #selector(RateViewController.selectThumb(_:)))
        tapSelect.numberOfTapsRequired = 1
        thumbImage.addGestureRecognizer(tapSelect)

        let touchImage: UITapGestureRecognizer = UITapGestureRecognizer()
        touchImage.addTarget(self, action: #selector(RateViewController.closeKeyboard(_:)))
        touchImage.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(touchImage)
        
        thumbImage.userInteractionEnabled = true
        thumbImage.layer.masksToBounds = true
        thumbImage.layer.cornerRadius = thumbImage.bounds.size.width/2
        thumbImage.layer.borderWidth = 1.0
        thumbImage.layer.borderColor = UIColor(red: 13/255, green: 70/255, blue: 131/255, alpha: 1.0).CGColor
        
        // Do any additional setup after loading the view.
        textDescription.text = currentTitle + "\r\n" + currentDescription
        
        
        labelQuestion1.text = Q1
        starRatingView1.initUI(0,spacing: 45.0,imageSize: 40.0, withOpacity: false)
        
        if  Q2 != "" {
            labelQuestion2.text = Q2
            starRatingView2.initUI(0,spacing: 45.0,imageSize: 40.0, withOpacity: false)
        }
        else
        {
            labelQuestion2.hidden = true
            starRatingView2.hidden = true
        }
        
        
        if Q3 != "" {
            labelQuestion3.text = Q3
            starRatingView3.initUI(0,spacing: 45.0,imageSize: 40.0, withOpacity: false)
        }
        else
        {
            labelQuestion3.hidden = true
            starRatingView3.hidden = true
        }
        
        thumbImage.image = imageLink
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func downloadImage(url:NSURL, frame:UIImageView){
        //print("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
             //   print("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                frame.image = UIImage(data: data!)
            }
        }
    }
}
