//
//  ShowReviewViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 24/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class ShowReviewViewController: UIViewController {
    
    @IBOutlet var rateTableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var textDescription: UITextView!
    @IBOutlet var viewNoReview: UIView!
    @IBOutlet var imageThumb: UIImageView!
    
    let url = "http://www.riccardorizzo.eu/rating/"
    
    var pin:PinAnnotation?
    var currentReviewID:String?
    var userInfos:User?
    var Descriptions:NSMutableArray = NSMutableArray()
    var Users:NSMutableArray = NSMutableArray()
    var Rates1:NSMutableArray = NSMutableArray()
    var Rates2:NSMutableArray = NSMutableArray()
    var Rates3:NSMutableArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationBar.topItem?.title = pin?.title
        textDescription.text = pin?.subtitle
        
        if let checkedUrl = NSURL(string:pin!.ImageLink) {
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
        do {
            try loadData()
        }
        catch {
            print(error)
        }
    }
    
    
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func downloadImage(url:NSURL, frame:UIImageView){
       // print("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
               // print("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                frame.image = UIImage(data: data!)
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
        vc.imageLink = pin!.ImageLink
        vc.currentRating = pin!.Rating
        vc.currentReviewID = pin!.ReviewID
        vc.Q1 = pin!.Question1
        vc.Q2 = pin!.Question2
        vc.Q3 = pin!.Question3
        self.presentViewController(vc, animated: true, completion: nil)
    }
    

    func loadData() throws {
        
        let searchUrl:String = url + "review.php"
        let params:NSMutableDictionary = NSMutableDictionary()
        
        params.setValue("get_rating", forKey: "command")
        params.setValue(pin?.ReviewID, forKey: "review_id")
        
        let jsonRequest = JSonHelper()
        let jsonData: AnyObject = try jsonRequest.getJson(searchUrl, dict: params)
        
        NSLog("\(jsonData)")
        if (jsonData is NSMutableDictionary) {
                NSLog("\(jsonData)")
        }
        else if (jsonData is NSMutableArray) {
            
            let returnData:NSMutableArray = jsonData as! NSMutableArray
            
            for P in returnData {
                let D:NSMutableDictionary = P as! NSMutableDictionary
                Descriptions.addObject(D.valueForKey("description")!)
                Users.addObject(D.valueForKey("user")!)
                Rates1.addObject(D.valueForKey("rate1")!.floatValue)
                Rates2.addObject(D.valueForKey("rate2")!.floatValue)
                Rates3.addObject(D.valueForKey("rate3")!.floatValue)
            }
            rateTableView.reloadData()
        }
        if Descriptions.count == 0 {
            viewNoReview.hidden = false
        }
    }
    
}

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
