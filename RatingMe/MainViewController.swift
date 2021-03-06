//
//  ViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 25/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import Alamofire
import SwiftyJSON
import RZViewActions

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

class ViewController: UIViewController, ReviewControllerProtocol,RateControllerProtocol {
    @IBOutlet var mainMap: MKMapView!
    @IBOutlet var searchBar: UISearchBar!

    @IBOutlet var menuButton: UIButton!


    let locationManager:CLLocationManager = CLLocationManager()
    var ThisImage:UIImageView = UIImageView()
    var pin:NSMutableArray?
    var currentAnnotation:PinAnnotation?
    var userInfos:User?
    var lastRegion:MKCoordinateRegion?
    var loginHappened:Bool = false
    var results:MKLocalSearchResponse? = MKLocalSearchResponse()
    let searchTableView: UITableView  =   UITableView()
    var preventRefreshBanner:Bool = false
    var olderPins:NSMutableArray = NSMutableArray()
    var numOfUnreadedMessage:NSInteger = 0

    var searchedItems:NSMutableArray?

    let newMailView = NewMailView()
    
    @IBOutlet var resultTableView: UITableView!
    
    @IBAction func logoutClick(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "loginData.UserID")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "loginData.UserName")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "loginData.UserCity")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "loginData.UserEmail")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "loginData.UserPasswordHash")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "loginData.UserSocialID")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        userInfos = nil
        loginHappened = false
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    func newNotification(){
    
            newMailView.frame = CGRectMake(0, 0, 270, 270)
            newMailView.center = self.view.center
            newMailView.backgroundColor = UIColor.clearColor()
        self.newMailView.transform = CGAffineTransformMakeScale(0.0, 0.0)
            self.view.addSubview(newMailView)
        
            let scaleUp = RZViewAction({ () -> Void in
                self.newMailView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, withDuration: 0.6)
        
            let wait = RZViewAction.waitForDuration(2.0)
        
            let scaleDown = RZViewAction({ () -> Void in
                self.newMailView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                }, withDuration: 0.5)
        
            let showMailImage = RZViewAction.sequence([scaleUp,wait,scaleDown])
        
            UIView.rz_runAction(showMailImage) { (finished) -> Void in
                self.newMailView.removeFromSuperview()
        }
        
    
        let notification = RemoteNotificationController()
        numOfUnreadedMessage = notification.getNotificationCount()!
        
        menuButton.setImage(LeftMenuButton.imageOfButtonMenu(numOfMessage: CGFloat(numOfUnreadedMessage), numberOfMessages: String("\(numOfUnreadedMessage as Int)")), forState: .Normal)
    }

    private func showLoadingHUD() {
        if !preventRefreshBanner {
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.labelText = "Loading data..."
        }
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    @IBAction func btnOpenLeftMenuClick(sender: AnyObject) {
        
        self.openLeft()
    }
    
    @IBAction func showReview(sender: UIButton) {
    
    }
    
    @IBAction func addReviewButtonClick(sender: UIButton) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ReviewSegue") {
            let reviewView = segue.destinationViewController as! ReviewViewController
            reviewView.userInfo = userInfos!
            reviewView.delegate = self
        }
    }
    
    @IBAction func searchByUserLocationButton(sender: UIBarButtonItem) {
        
        searchBar.endEditing(true)
        mainMap.showsUserLocation = true
        if(locationManager.location != nil) {
            searchByUserLocation(locationManager.location!.coordinate.latitude, lon: locationManager.location!.coordinate.longitude, center: true)
        }
    }
    
    @IBAction func swapMapTypeButtonClick(sender: UIBarButtonItem) {
        swapMapType()
    }
    
    func showMessageView() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("messageView") as! MessagesViewController
        vc.userInfo = userInfos!
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    func swapMapType() {
        if mainMap.mapType == MKMapType.Hybrid {
            mainMap.mapType = MKMapType.Satellite
        }
        else if mainMap.mapType == MKMapType.Satellite {
            mainMap.mapType = MKMapType.Standard
        }
        else if mainMap.mapType == MKMapType.Standard {
            mainMap.mapType = MKMapType.Hybrid
        }
    }
    
    func getScreenImage() -> UIImage {
        let imageSize:CGSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let viewImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return viewImage
    }
    
    func rippleView(view:UIImageView) {
        
        let animation = CATransition()
        //CATransition *animation=[CATransition animation];
        animation.delegate = self
        animation.duration = 4.75
       // animation.timingFunction = kCAMediaTimingFunctionEaseInEaseOut
        animation.type = "rippleEffect"
        animation.fillMode = kCAFillModeRemoved
        animation.endProgress=0.99;
        animation.removedOnCompletion = false
        view.layer.addAnimation(animation, forKey: nil)
    }
    
    
    func searchByUserLocation(lat:Double,lon:Double, center: Bool) {
        searchForLocation("",withRadius: zoomLevelForMap(),latitude_: lat,longitude_: lon, center:center)
    }
    
    
    func getCoordinatesByLocation(location:String) {
        
        let geocoder:CLGeocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks, error) -> Void in
      //  geocoder.geocodeAddressString(location, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] {
                self.centerMap(placemark.location!.coordinate.latitude, withLon: placemark.location!.coordinate.longitude)
            }
        }
    }
    
    func centerMap(lat: Double, withLon lon: Double) {
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mainMap.setRegion(region, animated: true)
    }
    
    func zoomLevelForMap() -> Double {
        //let scale:MKZoomScale = mainMap.bounds.size.width / CGFloat(mainMap.visibleMapRect.size.width)
        let mRect: MKMapRect = mainMap.visibleMapRect
        let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
        let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
        let currentDistWideInMeters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
        //let milesWide = currentDistWideInMeters / 1609.34  // number of meters in a mile
        
        //NSLog("Scale in KM:\(Double(currentDistWideInMeters)/1000)")
        
        return Double(currentDistWideInMeters)/1000  //In KM
    }
    
    func showReviewButtonClick(sender:UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("rateViewController") as! RateViewController
        let index = sender.tag
        NSLog("Visualizzo: \(index)")
        
        let pinArray: NSArray = mainMap.annotations as NSArray
        
        for item in pinArray {
            if( item is PinAnnotation) {
            let itm: PinAnnotation = item as! PinAnnotation
            if (itm.Tag == index) {
                vc.currentTitle = itm.title!
                vc.currentDescription = itm.subtitle!
            //    vc.imageLink = itm.ImageLink
                vc.currentRating = Double(itm.Rating)
                vc.currentReviewID = itm.ReviewID
                vc.Q1 = itm.Question1
                vc.Q2 = itm.Question2
                vc.Q3 = itm.Question3
                if(locationManager.location != nil) {
                    vc.lastLatitude = locationManager.location!.coordinate.latitude
                    vc.lastLongitude = locationManager.location!.coordinate.longitude
                }
                vc.delegate = self
                self.presentViewController(vc, animated: true, completion: nil)
                break
            }
            }
        }
    }
    
    func showInfoPanel(annotation: PinAnnotation) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ShowReviews") as! ShowReviewViewController
       // NSLog("Visualizzo: \(annotation.Tag)")
        vc.userInfos = userInfos!
        vc.pin = annotation
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showEULAView()
    {
            // Uncomment this to show EULA every time
            //NSUserDefaults.standardUserDefaults().setObject("0", forKey: "EULA")
            //NSUserDefaults.standardUserDefaults().synchronize()
        
            let eula = NSUserDefaults.standardUserDefaults().objectForKey("loginData.EULA") as? String
            if eula == nil {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EULAViewController") as! EULAViewController
                    self.presentViewController(vc, animated: true, completion: nil)
            }
    }

    override func viewDidAppear(animated: Bool) {
        
        self.closeLeft()

        if(userInfos == nil) {
            userInfos = loadLoginData()
        }
        if userInfos == nil {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else {
            if !loginHappened {
                loginHappened = true
                saveLoginData(userInfos!)
                preventRefreshBanner = false
                if (locationManager.location != nil) {
                    searchByUserLocation(locationManager.location!.coordinate.latitude, lon: locationManager.location!.coordinate.longitude, center: true)
                }
                else {
                    let region:MKCoordinateRegion = mainMap.region  // get the current region
                    searchByUserLocation(region.center.latitude, lon: region.center.longitude, center: false)
                }
                
                mainMap.showsUserLocation = true
                
               
            }
        }
        
        if userInfos != nil {
            let messages = MessageController()
            messages.getNumOfMessages((userInfos?.userID)!) { (result, errorMessage) -> () in
                let notification = RemoteNotificationController()
                let numberOfUnreadMessages:Int = result
                notification.setNotification(numberOfUnreadMessages)
                self.menuButton.setImage(LeftMenuButton.imageOfButtonMenu(numOfMessage: CGFloat(numberOfUnreadMessages), numberOfMessages: String("\(numberOfUnreadMessages as Int)")), forState: .Normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showEULAView()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveLoginData(userData: User) {
        
            UserController.saveLoginData(userData)
    }
    
    func loadLoginData() -> User? {
        
        return UserController.loadLoginData()
    }
    
    func setupUI(){
        let tapMapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer()
        tapMapRecognizer.addTarget(self, action: #selector(ViewController.mapTap(_:)))
        tapMapRecognizer.numberOfTapsRequired = 1
        mainMap.addGestureRecognizer(tapMapRecognizer)
        
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.tintColor            = UIColor.lightGrayColor()
        searchBar.barTintColor         = UIColor.whiteColor()
        searchBar.placeholder          = "Search for a place here"
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let rightScroll:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
        rightScroll.addTarget(self, action: #selector(ViewController.swipeMap(_:)))
        rightScroll.direction =  UISwipeGestureRecognizerDirection.Right
        mainMap.addGestureRecognizer(rightScroll)
        
        
        menuButton.setImage(LeftMenuButton.imageOfButtonMenu(numOfMessage: 0, numberOfMessages: "0"), forState: .Normal)
        
    }
    
    func swipeMap(selector:UISwipeGestureRecognizer) {
        NSLog("Map swiped")
    }
    
    func mapTap(tap:UIGestureRecognizer) {
       // NSLog("Tapped on map")
        
       /* if let popupView = self.view.viewWithTag(999) {
            popupView.removeFromSuperview()
        }
        */
    }
    
    func searchQuery(query:String) {
        
        let jsonRequest = JSonHelper()
        var params = [:]
        params = [  "search": query
                 ]
        
        jsonRequest.getJson("GET",apiUrl: jsonRequest.API_searchReviews, parameters: params as! [String:AnyObject]) { (jsonData) -> () in
            
            if jsonData == nil {
                return
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
                print(message)
                return
            }
            else if let message = json["error"].string {
                print(message)
                return
            }
            else if json.count > 0 {
                self.searchedItems = NSMutableArray()
                for (_,subJson):(String, JSON) in json {
                    let description = subJson[0]["description"].string!
                    let latitude = subJson[0]["latitude"].double!
                    let longitude = subJson[0]["longitude"].double!
                    let title = subJson[0]["title"].string!
                    let userName = subJson[0]["user"].string!
                    let coord:String = String(format:"{%f,%f}", latitude,longitude)
                    let point = CGPointFromString(coord)
                    let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
                    
                    var category:Category?
                    let cat = subJson[0]["category"]
                    if cat != nil {
                        category = Category(description: cat["description"].string!, id: "\(cat["id"].int!)", image: cat["image"].string!)
                    }
                    
                    let pin:PinAnnotation = PinAnnotation(coordinate: coordinate, title: title, subtitle: description, tag: 0, rating: 0, link: "", ID: "0", Q1: "", Q2: "", Q3: "", isAdv: "0", advImgLink: "", category: category, user_name: userName)
                    
                    self.searchedItems?.addObject(pin)
                }
            

                self.searchTableView.tag           =   999
                self.searchTableView.frame         =   self.mainMap.frame
                self.searchTableView.delegate      =   self
                self.searchTableView.dataSource    =   self
            
                self.searchTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            
                self.view.addSubview(self.searchTableView)
                self.searchTableView.reloadData()
            }
            else {
                let request = MKLocalSearchRequest()
                request.naturalLanguageQuery = query
                
                //let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                request.region = self.mainMap.region
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                let search = MKLocalSearch(request: request)
                search.startWithCompletionHandler { (response, error) -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if response != nil {
                        self.results = response
                        self.resultTableView.hidden = false
                        self.resultTableView.reloadData()
                    }
                }
            }
        }
    }

    
    func response(latitude_:String,longitude_:String,radius_:String) {
        
        
    }


    func searchForLocation(location:String, withRadius radius_:Double, latitude_:Double=0.0, longitude_:Double=0.0, center:Bool) {
        
        let jsonRequest = JSonHelper()
        let Pins:NSMutableArray = NSMutableArray()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        showLoadingHUD()
        
        var params = [:]
        
        var radius = radius_
        if(radius < 1) {
            radius = 1
        }
        
        let new_location = location.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
    
        if latitude_==0.0 && longitude_==0.0 {
            
            params = [  "address:": new_location,
                        "radius": NSString(format: "%.2f", radius)
                     ]
        }
        else {
            params = [
                        "lat": "\(latitude_)",
                        "lon": "\(longitude_)",
                        "radius":"\(radius_)"
                     ]
        }
    
        jsonRequest.getJson("GET",apiUrl: jsonRequest.API_showReviews, parameters: params as! [String:AnyObject]) { (jsonData) -> () in
            if jsonData == nil {
                return
            }
            let json = JSON(jsonData!)
        
            if let message = json[0]["error"].string {
                print(message)
                return
            }
            if let message = json["error"].string {
                print(message)
                return
            }
    
            for (key,subJson):(String, JSON) in json {
                let description = subJson[0]["description"].string!
                let image = subJson[0]["picture"].string ?? ""
                let latitude = subJson[0]["latitude"].double!
                let longitude = subJson[0]["longitude"].double!
                let userName = subJson[0]["user"].string!
                let rating = subJson[0]["point"].int!
                let title = subJson[0]["title"].string!
                let id = subJson[0]["id"].int!
                //print(subJson[0]["point"])
                let reviewID = String(format: "\(id)")
                let question1 = subJson[0]["question1"].string!
                let question2 = subJson[0]["question2"].string!
                let question3 = subJson[0]["question3"].string!
                let isAdvertisement = subJson[0]["is_advertisement"].string ?? "0"
                let advertisementImageLink = subJson[0]["ad_image_link"].string ?? ""
                
                var category:Category?
                let cat = subJson[0]["category"]
                if cat != nil {
                    category = Category(description: cat["description"].string!, id: "\(cat["id"].int!)", image: cat["image"].string!)
                }
            
                let coord:String = String(format:"{%f,%f}", latitude,longitude)
                let point = CGPointFromString(coord)
                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
                
                let tag = Int(key)! + 1
                let pinPoint = PinAnnotation(coordinate: coordinate, title:title, subtitle: description, tag: tag ,rating: rating, link: image, ID: reviewID, Q1: question1, Q2: question2, Q3: question3, isAdv: isAdvertisement, advImgLink: advertisementImageLink, category: category, user_name: userName)
            
                Pins.addObject(pinPoint)

            }
            
            var isEqual = true
            if Pins.count != self.olderPins.count {
                isEqual = false
            }
            else {
                if Pins.count > 0 {
                    for i:Int in 0...(Pins.count-1) {
                        if (Pins[i] as! PinAnnotation).ReviewID != (self.olderPins[i] as! PinAnnotation).ReviewID {
                            isEqual = false
                            break
                        }
                    }
                }
            }
            
            
            if !isEqual {
                self.olderPins = Pins
                
                if self.mainMap.annotations.count > 0 {
                    for annotation in self.mainMap.annotations {
                        let annView = self.mainMap.viewForAnnotation(annotation)
                        if annView != nil{
                            annView!.alpha = 1.0
                            //annView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                        
                            UIView.animateWithDuration(0.1, animations: { () -> Void in
                                //annView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                                annView!.alpha = 0.0
                                }, completion: { (end) -> Void in
                                    self.mainMap.removeAnnotations(self.mainMap.annotations)
                                    for pinPoint in Pins {
                                        self.mainMap.addAnnotation(pinPoint as! MKAnnotation)
                                    }
                            })

                        }
                    }
                }
                else {
                    for pinPoint in Pins {
                        self.mainMap.addAnnotation(pinPoint as! MKAnnotation)
                    }
                }
            
                
                //self.mainMap.removeAnnotations(self.mainMap.annotations)
                
           //     for pinPoint in Pins {
            //        self.mainMap.addAnnotation(pinPoint as! MKAnnotation)
             //   }
                
            }
            
            
            if(center) {
                self.fitAnnotation(Pins)
            }

        
            if(center && latitude_ > 0 && longitude_ > 0) {
                self.centerMap(latitude_, withLon: longitude_)
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.hideLoadingHUD()
    }

    }
    
    
    func fitAnnotation(point:NSArray) {
        var zoomRect:MKMapRect = MKMapRectNull;
        for annotation in point {
            let loc:PinAnnotation = annotation as! PinAnnotation
            let annotationPoint:MKMapPoint = MKMapPointForCoordinate(loc.coordinate);
            let pointRect:MKMapRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect;
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
        mainMap.setVisibleMapRect(zoomRect, animated: true);
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
            //    print("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                frame.image = UIImage(data: data!)
            }
        }
    }
    
}

extension ViewController:MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      if loginHappened {
        if lastRegion?.center.latitude != mainMap.region.center.latitude {
            preventRefreshBanner = true
            lastRegion = mainMap.region
            
            if let popupView = self.view.viewWithTag(999) {
                popupView.removeFromSuperview()
            }
            
            let region:MKCoordinateRegion = mainMap.region  // get the current region
            searchByUserLocation(region.center.latitude, lon: region.center.longitude, center: false)
        }
      }
    }
 
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        for annView in views
        {
            if !annView.isKindOfClass(MKUserLocation) {
            annView.alpha = 0.0
            //annView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                //annView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                annView.alpha = 1.0
                }, completion: { (end) -> Void in
                    //annView.transform = CGAffineTransformIdentity
                    annView.alpha = 1.0
            })
            
            }
 
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
     /*   if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
       */
        
        mapView.showsUserLocation = true
        
        let pinAnnotationView = PinAnnotationView(annotation: annotation, reuseIdentifier: "Points")
        pinAnnotationView.canShowCallout = false
        if (pinAnnotationView.annotation is PinAnnotation)
        {
            let currAnnotation:PinAnnotation = pinAnnotationView.annotation as! PinAnnotation
            pinAnnotationView.disclosureBlock = { NSLog("selected Pin"); self.showInfoPanel(currAnnotation) }
            return pinAnnotationView
        }
        
        return nil
    }
    

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if let rr:PinAnnotationView = view as? PinAnnotationView {
            rr.shrink()
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let rr:PinAnnotationView = view as? PinAnnotationView {
            rr.canShowCallout = false
            rr.expand()
            if let annotation = view.annotation as? PinAnnotation {
                NSLog("Le tre domande: \(annotation.Question1) - \(annotation.Question2) - \(annotation.Question3)")
            }
        }

    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
}

extension ViewController:UISearchControllerDelegate {
    
}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag != 999 {
            if let _ = self.results?.mapItems {
                return self.results!.mapItems.count
            }
            else {
                return 0
            }
        }
        else {
            return self.searchedItems!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        if tableView.tag != 999 {
            let cell:UITableViewCell =  UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "SearchCell")
    
            let newRecordName = (self.results!.mapItems[indexPath.row] ).placemark.name
            let newRecordAddress = (self.results!.mapItems[indexPath.row] ).placemark
            let addressOnly = newRecordAddress.title //newRecordAddress.name + ", " + newRecordAddress.title
        
            cell.textLabel!.text = newRecordName
            cell.detailTextLabel!.text = addressOnly
        
            return cell;
        }
        else
        {
            //let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
            let cellIdentifier = "Cell"
            
            var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) //as! UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
            }
            
            cell!.textLabel?.text = (self.searchedItems![indexPath.row] as? PinAnnotation)?.title
            cell!.detailTextLabel?.text = (self.searchedItems![indexPath.row] as? PinAnnotation)?.subtitle
            return cell!

        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag != 999 {
            self.resultTableView.hidden = true
            searchBar.text = ""
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.endEditing(true)
        
            let latitude = (self.results!.mapItems[indexPath.row]).placemark.location!.coordinate.latitude
            let longitude = (self.results!.mapItems[indexPath.row]).placemark.location!.coordinate.longitude
            self.centerMap(latitude, withLon: longitude)
        }
        else {
            let latitude = (self.searchedItems![indexPath.row] as? PinAnnotation)?.coordinate.latitude
            let longitude = (self.searchedItems![indexPath.row] as? PinAnnotation)?.coordinate.longitude
            self.centerMap(latitude!, withLon: longitude!)
            
            tableView.removeFromSuperview()
        }
    }
    
}

extension ViewController:CLLocationManagerDelegate {
    
    func locationManager(_manager: CLLocationManager,didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    }
    
}

extension ViewController:UIPopoverPresentationControllerDelegate {
    
}

extension ViewController:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text!.characters.count > 0 {
            searchBar.resignFirstResponder()
            searchBar.endEditing(true)
            searchQuery(searchBar.text!)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        self.resultTableView.hidden = true
        self.searchTableView.removeFromSuperview()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        self.resultTableView.hidden = true
        self.searchTableView.removeFromSuperview()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

