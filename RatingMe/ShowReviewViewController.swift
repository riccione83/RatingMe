//
//  ShowReviewViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 24/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import MBProgressHUD
import Popover

class ShowReviewViewController: UIViewController, NSURLConnectionDataDelegate {
    
    @IBOutlet var rateTableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var textDescription: UITextView!
    @IBOutlet var viewNoReview: UIView!
    @IBOutlet var imageThumb: CustomImageView! //UIImageView!
    @IBOutlet var darkBackgroundView: UIView!
    
    var pin:PinAnnotation?
    var currentReviewID:String?
    var userInfos:User?
    var Descriptions:NSMutableArray = NSMutableArray()
    var Users:NSMutableArray = NSMutableArray()
    var Rates1:NSMutableArray = NSMutableArray()
    var Rates2:NSMutableArray = NSMutableArray()
    var Rates3:NSMutableArray = NSMutableArray()
    var downloadedMutableData:NSMutableData?
    var urlResponse:NSURLResponse?
    var imageShowedInBig = false
    var prevFrame:CGRect = CGRect.null
    var currentRandomGeneratedCode = ""
    
    let jsonRequest = JSonHelper()

    private var texts = ["Add a Rate", "Share", "Report this Review","Block this user"]
    
    private var popover: Popover!
    private var popoverOptions: [PopoverOption] = [
        .Type(.Down),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Wait..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func showImage() {
        if (!imageShowedInBig) {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.darkBackgroundView.hidden = false
                self.darkBackgroundView.alpha = 1.0
                self.prevFrame = self.imageThumb.frame
                self.imageThumb.layer.borderColor = UIColor(red: 13/255, green: 70/255, blue: 131/255, alpha: 0.0).CGColor
                self.imageThumb.contentMode = UIViewContentMode.ScaleAspectFit
                self.imageThumb.frame = UIScreen.mainScreen().bounds
                }, completion: { (finished) -> Void in
                    self.imageShowedInBig = true
            })
        }
        else {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.imageThumb.frame = self.prevFrame
                self.darkBackgroundView.hidden = true
                self.darkBackgroundView.alpha = 0.0
                }, completion: { (finished) -> Void in
                    self.imageThumb.contentMode = UIViewContentMode.ScaleAspectFill
                    self.imageThumb.layer.borderColor = UIColor(red: 13/255, green: 70/255, blue: 131/255, alpha: 1.0).CGColor
                    self.imageShowedInBig = false
            })
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
        let touchImage: UITapGestureRecognizer = UITapGestureRecognizer()
        touchImage.addTarget(self, action: "showImage")
        touchImage.numberOfTapsRequired = 1
        imageThumb.addGestureRecognizer(touchImage)
        
        
        navigationBar.topItem?.title = pin?.title
        textDescription.text = pin?.subtitle
        currentReviewID = pin!.ReviewID
        imageThumb.userInteractionEnabled = true
        imageThumb.layer.masksToBounds = true
        imageThumb.layer.cornerRadius = imageThumb.bounds.size.width/2
        imageThumb.layer.borderWidth = 1.0
        imageThumb.layer.borderColor = UIColor(red: 13/255, green: 70/255, blue: 131/255, alpha: 1.0).CGColor
        
        var imagePath = ""
            if pin!.ImageLink.containsString("http") {
                imagePath = pin!.ImageLink
            }
            else {
                imagePath = jsonRequest.url + pin!.ImageLink
            }
        
            if let checkedUrl = NSURL(string: imagePath) {
                downloadImage(checkedUrl,frame: imageThumb)
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        darkBackgroundView.hidden = true
        viewNoReview.hidden = true
        Descriptions.removeAllObjects()
        Users.removeAllObjects()
        Rates1.removeAllObjects()
        Rates2.removeAllObjects()
        Rates3.removeAllObjects()
        
        loadData()
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func downloadImage(url:NSURL, frame:UIImageView) {
        
        let downloader:SDWebImageDownloader = SDWebImageDownloader.sharedDownloader()
        
        downloader.downloadImageWithURL(url, options: SDWebImageDownloaderOptions.AllowInvalidSSLCertificates, progress: { (receivedSize, expectedSize) -> Void in
                if receivedSize > 0 {
                    let received:Float = ((Float(receivedSize)*100.0)/Float(expectedSize))/100.0
                    self.imageThumb.updateProgress(CGFloat(receivedSize), expectedSize: CGFloat(expectedSize))
                    print("=>",received,expectedSize)
                }
            })
            { (image, data, error, finished) -> Void in  //Download finished
                if ((image != nil) && finished == true) {
                    frame.image = image
                    self.imageThumb.revealImage()
            }
        }
    }

    
    @IBAction func returnButtonClick(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func newReviewButtonClick(sender: UIBarButtonItem) {
        
        let startPoint = CGPoint(x: self.view.frame.width - 25, y: 55)
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollEnabled = false
        tableView.tag = 999
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        self.popover.show(tableView, point: startPoint)
    }
    
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    
    func askForSureWhenReportIsSelected()
    {
            self.currentRandomGeneratedCode = self.randomStringWithLength(6) as String
        
            //Create the AlertController
            let actionSheetController: UIAlertController = UIAlertController(title: "Report abuse", message: "This make the reported Review hidden to all User. Please insert this code below to verify your choose: " + self.currentRandomGeneratedCode, preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Do nothing
            }
            actionSheetController.addAction(cancelAction)
            //Create and an option action
            let nextAction: UIAlertAction = UIAlertAction(title: "Report", style: .Default) { action -> Void in
                print(actionSheetController.textFields?.first?.text)
                if self.currentRandomGeneratedCode == actionSheetController.textFields?.first?.text?.uppercaseString {
                    self.reportAbuseForSelectedReview()
                }
                else
                {
                    self.showMessage("", detail: "The verify code doesn't match. Please try again")
                    
                }
            }
            actionSheetController.addAction(nextAction)
            //Add a text field
            actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
                //TextField configuration
                textField.textColor = UIColor.blueColor()
            }
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func askForSureWhenReportUserIsSelected()
    {
        self.currentRandomGeneratedCode = self.randomStringWithLength(6) as String
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Report abuse", message: "This make the account of selected User locked. Please insert this code below to verify your choose: " + self.currentRandomGeneratedCode, preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do nothing
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Report", style: .Default) { action -> Void in
            print(actionSheetController.textFields?.first?.text)
            if self.currentRandomGeneratedCode == actionSheetController.textFields?.first?.text?.uppercaseString {
                self.reportAbuseForSelectedUser()
            }
            else
            {
                self.showMessage("", detail: "The verify code doesn't match. Please try again")
                
            }
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blueColor()
        }
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func showMessage(message:String, detail:String?) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if (detail != nil) {
            hud.detailsLabelText = detail
        }
        hud.mode = MBProgressHUDMode.Text
        hud.dimBackground = true
        hud.hide(true, afterDelay: 5.0)
    }

    
    func reportAbuseForSelectedUser()
    {
        let loginHelper = JSonHelper()
        //currentReviewID
        
        let params = [
            "review_id": currentReviewID!
        ]
       showLoadingHUD()
        
       loginHelper.getJson("GET",apiUrl: loginHelper.API_reportUser, parameters: params) { (jsonData) -> () in
        
        self.hideLoadingHUD()
            if jsonData == nil {
                self.showMessage("", detail: "Error on report the User. Please check your connection")
            }
            else {
                let json = JSON(jsonData!)
                if let message = json["error"].string {
                    print(message)
                    self.showMessage("", detail: "Error while reporting User account. " + message)
                }
                else if let message = json["message"].string {
                    print(message)
                    self.showMessage("", detail: "Great! " + message)
                }
                else {
                    self.showMessage("", detail: "Sorry, unknow error. Try again.")
                }
            }
        }
        
    }
    
    
    func reportAbuseForSelectedReview()
    {
        let loginHelper = JSonHelper()
        //currentReviewID
        
        let params = [
            "review_id": currentReviewID!
        ]
        showLoadingHUD()
        loginHelper.getJson("GET",apiUrl: loginHelper.API_reportReviewAbuse, parameters: params) { (jsonData) -> () in
            
            self.hideLoadingHUD()
            if jsonData == nil {
                self.showMessage("", detail: "Error on report the Review. Please check your connection")
            }
            else {
                let json = JSON(jsonData!)
                if let message = json["error"].string {
                    print(message)
                    self.showMessage("", detail: "Error while reporting the Review. " + message)
                }
                else if let message = json["message"].string {
                    print(message)
                    self.showMessage("", detail: "Great! " + message)
                }
                else {
                     self.showMessage("", detail: "Sorry, unknow error. Try again.")
                }
            }
        }
    }

    func showNewRatingView() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("rateViewController") as! RateViewController
        let index = pin?.Tag
        NSLog("New Review for: \(index)")
        
        vc.userInfos = userInfos!
        vc.currentTitle = pin!.title!
        vc.currentDescription = pin!.subtitle!
        vc.imageLink = imageThumb.image // pin!.ImageLink
        vc.currentRating = Double(pin!.Rating)
        vc.currentReviewID = pin!.ReviewID
        vc.Q1 = pin!.Question1
        vc.Q2 = pin!.Question2
        vc.Q3 = pin!.Question3
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func shareButtonTapped() {
            let title:String = self.pin!.title!
            let Description:String = self.pin!.subtitle!
            let reviewImage:UIImage = self.imageThumb.image!
            let review =  title + " - " + Description
            let welcome = "Hey! Please give a look at this Review! "
            let link = "http://www.ratingme.eu/reviews/" + currentReviewID!
            let shareItems:Array = [reviewImage, welcome, review, link]
            let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
    }

    func loadData() {
        let params = [ "id": pin!.ReviewID]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_showRatings, parameters: params) { (jsonData) -> () in

            if jsonData == nil {
                return
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                return
            }
            
            for (key,subJson):(String, JSON) in json {
                print(key)
                print(subJson[0]["description"])
                
                self.Descriptions.addObject(subJson[0]["description"].string!)
                self.Users.addObject(subJson[0]["user_name"].string!)
                self.Rates1.addObject(subJson[0]["rate1"].float!)
                if subJson[0]["rate2"].float != nil {
                    self.Rates2.addObject(subJson[0]["rate2"].float!)
                }
                else
                {
                    self.Rates2.addObject(0.0)
                }
                if subJson[0]["rate3"].float != nil {
                    self.Rates3.addObject(subJson[0]["rate3"].float!)
                }
                else
                {
                    self.Rates3.addObject(0.0)
                }
            }
            
            self.rateTableView.reloadData()
            if self.Descriptions.count == 0 {
                self.viewNoReview.hidden = false
            }
        }
    }
} //End
    
extension ShowReviewViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 999 {
            self.popover.dismiss()
            if indexPath.row == 0 {
                showNewRatingView()
            }
            if indexPath.row == 1 {
                shareButtonTapped()
            }
            if indexPath.row == 2 {
                askForSureWhenReportIsSelected()
            }
            if indexPath.row == 3 {
                askForSureWhenReportUserIsSelected()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 999 {
            return 4
        }
        else {
            return Descriptions.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.tag == 999 {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel?.text = self.texts[indexPath.row]
            return cell
        }
        else {
            
        let myCell:RateCustomCell = rateTableView.dequeueReusableCellWithIdentifier("CustomCell") as! RateCustomCell
        
        myCell.lblQuestion1.text = pin?.Question1
        
        if pin?.Question2 != nil && pin?.Question2 != "" {
            myCell.lblQuestion2.text = pin?.Question2
        }
        else
        {
            myCell.lblQuestion2.hidden = true
            myCell.starRatingQuestion2.hidden = true
        }
        
        if pin?.Question3 != nil && pin?.Question3 != "" {
            myCell.lblQuestion3.text = pin?.Question3
        }
        else {
            myCell.lblQuestion3.hidden = true
            myCell.starRatingQuestion3.hidden = true
        }
        
        let userName = Users.objectAtIndex(indexPath.row) as! String
        
        myCell.labelNoteTitle.text = String(format: "Note by \(userName)")
        
        myCell.labelNote.text = Descriptions.objectAtIndex(indexPath.row) as? String
    
        myCell.starRatingQuestion1.setRating(Rates1.objectAtIndex(indexPath.row) as! Int)
        myCell.starRatingQuestion2.setRating(Rates2.objectAtIndex(indexPath.row) as! Int)
        myCell.starRatingQuestion3.setRating(Rates3.objectAtIndex(indexPath.row) as! Int)
        
      /*  myCell.starRatingQuestion1.initUI(Rates1.objectAtIndex(indexPath.row) as! Int, spacing: 22, imageSize: 20, withOpacity: false)
        myCell.starRatingQuestion2.initUI(Rates2.objectAtIndex(indexPath.row) as! Int, spacing: 22, imageSize: 20, withOpacity: false)
        myCell.starRatingQuestion3.initUI(Rates3.objectAtIndex(indexPath.row) as! Int, spacing: 22, imageSize: 20, withOpacity: false)
    */
        
        myCell.starRatingQuestion1.userInteractionEnabled = false
        myCell.starRatingQuestion2.userInteractionEnabled = false
        myCell.starRatingQuestion3.userInteractionEnabled = false
        
        return myCell
        }
    }
    
}
