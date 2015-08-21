//
//  RateViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 02/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

protocol RateControllerProtocol {
    func searchByUserLocation(lat:Double,lon:Double, center: Bool)
}

class RateViewController: UIViewController {

    let url = "http://www.riccardorizzo.eu/rating/"
    
    var delegate:RateControllerProtocol? = nil
    
    var isFullscreen = false
    var oldFrame: CGRect = CGRectMake(0, 0, 0, 0)
    
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
    
    var userInfos:User?
    var currentTitle:String = ""
    var currentDescription:String = ""
    var imageLink:String = ""
    var currentRating:String = ""
    var currentReviewID:String = ""
    var lastLatitude:Double = 0.0;
    var lastLongitude:Double = 0.0;
    var incrementValue = 0
    var Q1:String = ""
    var Q2:String = ""
    var Q3:String = ""
    
    @IBAction func feedbackClick(sender: AnyObject) {
        
        if !isFullscreen {
            var rating = currentRating.toInt()
            
            var divisor = 1
            let rate1 = starRatingView1.currentRating
            var rate2 = 0
            var rate3 = 0
            
            if starRatingView2 != nil && !starRatingView2.hidden {
                rate2 = starRatingView2.currentRating
                divisor++
            }
            
            if starRatingView3 != nil && !starRatingView3.hidden {
                rate3 = starRatingView3.currentRating
                divisor++
            }
            
            rating = (starRatingView1.currentRating + starRatingView2.currentRating + starRatingView3.currentRating) / divisor
            
            newRating(currentReviewID, user_id: userInfos!.userID,user_name: userInfos!.userName, rate: rating!, description: txtRateDescription.text, rate_q1: starRatingView1.currentRating,rate_q2: starRatingView2.currentRating, rate_q3: starRatingView3.currentRating)
        }
        else {
            thumbImage.frame = oldFrame
            isFullscreen = false
            textDescription.layer.cornerRadius = 0
            textDescription.backgroundColor = UIColor.clearColor()
            textDescription.alpha = 1
            starRatingView1.alpha = 1
            starRatingView2.alpha = 1
            starRatingView3.alpha = 1
            txtRateDescription.alpha = 1
        }
    }
    
    @IBAction func returnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    

    
    
    func newRating(review_id:String, user_id:String,user_name:String, rate:Int, description:String, rate_q1:Int, rate_q2:Int, rate_q3:Int) {
    
        let rating = String(format: "\(rate)")
        var sUrl:String = url + "review.php"
        
        let q1 = "\(rate_q1)"
        let q2 = "\(rate_q2)"
        let q3 = "\(rate_q3)"

        var params:NSMutableDictionary = NSMutableDictionary()
        params.setValue("set_rating", forKey: "command")
        params.setValue(review_id, forKey: "review_id")
        params.setValue(user_id, forKey: "user_id")
        params.setValue(user_name, forKey: "user_name")
        params.setValue(rating, forKey: "rate")
        params.setValue(description, forKey: "rate_description")
        params.setValue(q1, forKey: "rate_q1")
        params.setValue(q2, forKey: "rate_q2")
        params.setValue(q3, forKey: "rate_q3")
        
        
        let jsonRequest = JSonHelper.new()
        let jsonData = jsonRequest.getJson(sUrl,dict: params) as! NSMutableDictionary
        
        if (jsonData.valueForKey("message") != nil) {
            NSLog("\(jsonData)")
            delegate?.searchByUserLocation(lastLatitude, lon: lastLongitude, center: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            let error_str:String = jsonData.valueForKey("error") as! String
            NSLog("\(error_str)")
            showMessage(error_str)
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
        var linkArr = split(link) {$0 == "&"}
        var temp = split(linkArr[3]) {$0 == "="}
        var currHeading = temp[1]
        var new_Link:String = ""
        var i = 0

        if (incrementValue == 0) {
            incrementValue = currHeading.toInt()! + increment
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
            i++
        }
        NSLog("\(new_Link)")
        
        if let checkedUrl = NSURL(string:new_Link) {
            downloadImage(checkedUrl,frame: thumbImage)
        }
    }
    
    func swipeImage(sender: UISwipeGestureRecognizer) {
        
        if (sender.direction == UISwipeGestureRecognizerDirection.Left) {
            NSLog("Swipe to left")
            analyzeImageLink(imageLink, increment: 45)
        }
        else if (sender.direction == UISwipeGestureRecognizerDirection.Right) {
                NSLog("Swipe to right")
                analyzeImageLink(imageLink,increment: -45)
        }
    }
    
    func selectThumb(sender: UITapGestureRecognizer) {
        NSLog("Touble tap")
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelay(0.0)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
        if(!isFullscreen) {
            oldFrame = thumbImage.frame
            thumbImage.frame = self.view.frame
            isFullscreen = true
            textDescription.backgroundColor = UIColor.whiteColor()
            textDescription.alpha = 0.0
            starRatingView1.alpha = 0.0
            starRatingView2.alpha = 0.0
            starRatingView3.alpha = 0.0
            txtRateDescription.alpha = 0.0
        }
        else {
            thumbImage.frame = oldFrame
            isFullscreen = false
            textDescription.layer.cornerRadius = 0
            textDescription.backgroundColor = UIColor.clearColor()
            textDescription.alpha = 1
            starRatingView1.alpha = 1
            starRatingView2.alpha = 1
            starRatingView3.alpha = 1
            txtRateDescription.alpha = 1
        }
        UIView.commitAnimations()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        txtRateDescription.resignFirstResponder()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 150
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        let rightScroll:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
        rightScroll.addTarget(self, action: "swipeImage:")
        rightScroll.direction =  UISwipeGestureRecognizerDirection.Right
        thumbImage.addGestureRecognizer(rightScroll)
        
        let leftScroll:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
        leftScroll.addTarget(self, action: "swipeImage:")
        leftScroll.direction =  UISwipeGestureRecognizerDirection.Left
        thumbImage.addGestureRecognizer(leftScroll)
        
        let tapSelect:UITapGestureRecognizer = UITapGestureRecognizer()
        tapSelect.addTarget(self, action: "selectThumb:")
        tapSelect.numberOfTapsRequired = 2
        thumbImage.addGestureRecognizer(tapSelect)

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
        
        if let checkedUrl = NSURL(string:imageLink) {
            downloadImage(checkedUrl,frame: thumbImage)
        }
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
        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                frame.image = UIImage(data: data!)
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
