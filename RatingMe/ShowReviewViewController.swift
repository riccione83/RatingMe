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

class ShowReviewViewController: UIViewController, NSURLConnectionDataDelegate {
    
    @IBOutlet var rateTableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var textDescription: UITextView!
    @IBOutlet var viewNoReview: UIView!
    @IBOutlet var imageThumb: CustomImageView! //UIImageView!
    
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
    
    let jsonRequest = JSonHelper()

    
    func showImage() {
        if (!imageShowedInBig) {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.prevFrame = self.imageThumb.frame
                self.imageThumb.contentMode = UIViewContentMode.ScaleAspectFit
                self.imageThumb.frame = UIScreen.mainScreen().bounds
                }, completion: { (finished) -> Void in
                    self.imageShowedInBig = true
            })
        }
        else {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.imageThumb.frame = self.prevFrame
              //  self.imageThumb.contentMode = UIViewContentMode.ScaleToFill
                }, completion: { (finished) -> Void in
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
        imageThumb.userInteractionEnabled = true
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
                self.Rates2.addObject(subJson[0]["rate2"].float!)
                self.Rates3.addObject(subJson[0]["rate2"].float!)
            }
            
            self.rateTableView.reloadData()
            if self.Descriptions.count == 0 {
                self.viewNoReview.hidden = false
            }
        }
    }
} //End

    
extension ShowReviewViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Descriptions.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
        myCell.starRatingQuestion1.initUI(Rates1.objectAtIndex(indexPath.row) as! Int, spacing: 22, imageSize: 20, withOpacity: false)
        myCell.starRatingQuestion2.initUI(Rates2.objectAtIndex(indexPath.row) as! Int, spacing: 22, imageSize: 20, withOpacity: false)
        myCell.starRatingQuestion3.initUI(Rates3.objectAtIndex(indexPath.row) as! Int, spacing: 22, imageSize: 20, withOpacity: false)
        
        myCell.starRatingQuestion1.userInteractionEnabled = false
        myCell.starRatingQuestion2.userInteractionEnabled = false
        myCell.starRatingQuestion3.userInteractionEnabled = false
        
        return myCell
    }
    
}
