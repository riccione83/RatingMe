//
//  ShowReviewViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 24/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class ShowReviewViewController: UIViewController {

    
    //let url = "http://localhost:8888/rating/"
    let url = "http://www.riccardorizzo.eu/rating/"
    
    var pin:PinAnnotation?
    var currentReviewID:String?
    @IBOutlet var rateTableView: UITableView!
    
    var Descriptions:NSMutableArray = NSMutableArray.new()
    var Users:NSMutableArray = NSMutableArray.new()
    var Rates1:NSMutableArray = NSMutableArray.new()
    var Rates2:NSMutableArray = NSMutableArray.new()
    var Rates3:NSMutableArray = NSMutableArray.new()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        Descriptions.removeAllObjects()
        Users.removeAllObjects()
        Rates1.removeAllObjects()
        Rates2.removeAllObjects()
        Rates3.removeAllObjects()
        loadData()
    }
    
    @IBAction func returnButtonClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func newReviewButtonClick(sender: UIButton) {
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("rateViewController") as! RateViewController
       let index = pin?.Tag
        NSLog("New Review for: \(index)")
        
        vc.currentTitle = pin!.title
        vc.currentDescription = pin!.subtitle
        vc.imageLink = pin!.ImageLink
        vc.currentRating = pin!.Rating
        vc.currentReviewID = pin!.ReviewID
        vc.Q1 = pin!.Question1
        vc.Q2 = pin!.Question2
        vc.Q3 = pin!.Question3
     /*   if(locationManager.location != nil) {
            vc.lastLatitude = locationManager.location.coordinate.latitude
            vc.lastLongitude = locationManager.location.coordinate.longitude
        }*/
        //vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    

    func loadData() {
        
        var searchUrl:String = url + "review.php"
        var params:NSMutableDictionary = NSMutableDictionary()
        
        params.setValue("get_rating", forKey: "command")
        params.setValue(pin?.ReviewID, forKey: "review_id")
        
        let jsonRequest = JSonHelper.new()
        let jsonData: AnyObject = jsonRequest.getJson(searchUrl, dict: params)
        
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

extension ShowReviewViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Descriptions.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell:RateCustomCell = rateTableView.dequeueReusableCellWithIdentifier("CustomCell") as! RateCustomCell
        
        myCell.lblQuestion1.text = pin?.Question1
        myCell.lblQuestion2.text = pin?.Question2
        myCell.lblQuestion3.text = pin?.Question3
        
        myCell.labelNote.text = Descriptions.objectAtIndex(indexPath.row) as? String
        
        myCell.progressQuestion1.progress = (Rates1.objectAtIndex(indexPath.row) as! Float)/5
        myCell.progressQuestion2.progress = (Rates2.objectAtIndex(indexPath.row) as! Float)/5
        myCell.progressQuesiton3.progress = (Rates3.objectAtIndex(indexPath.row) as! Float)/5
    
        return myCell
    }
    
}
