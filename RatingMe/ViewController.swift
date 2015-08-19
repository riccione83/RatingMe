//
//  ViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 25/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

class ViewController: UIViewController, ReviewControllerProtocol,RateControllerProtocol {
    @IBOutlet var mainMap: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
  //  @IBOutlet var testImage: UIImageView!
    
    let locationManager:CLLocationManager = CLLocationManager.new()
    var ThisImage:UIImageView = UIImageView.new()
    var pin:NSMutableArray?
    var currentAnnotation:PinAnnotation?
    
    //let url = "http://localhost:8888/rating/"
    let url = "http://www.riccardorizzo.eu/rating/"
    
    
    @IBAction func showReview(sender: UIButton) {
    
    }
    
    @IBAction func addReviewButtonClick(sender: UIButton) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ReviewSegue") {
            let reviewView = segue.destinationViewController as! ReviewViewController
            reviewView.delegate = self
        }
    /*    else if(segue.identifier == "showReview") {
            let formReview = segue.destinationViewController as! ShowReviewViewController
            formReview.pin = currentAnnotation
        }
*/
    }
    
    @IBAction func searchByUserLocationButton(sender: UIBarButtonItem) {
        
        searchBar.endEditing(true)
        mainMap.showsUserLocation = true
        if(locationManager.location != nil) {
            searchByUserLocation(locationManager.location.coordinate.latitude, lon: locationManager.location.coordinate.longitude, center: true)
        }
    }
    
    @IBAction func swapMapTypeButtonClick(sender: UIBarButtonItem) {
        swapMapType()
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
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
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
        
        var locationQuery = location.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        /*var searchUrl = "http://maps.google.com/maps/api/geocode/json?address="+locationQuery
        searchUrl = searchUrl + "&sensor=false&region=$region"
        */
        
        var searchUrl = "http://maps.google.com/maps/api/geocode/json";
        var postParams = "?address="+locationQuery + "&sensor=false&region=$region"
        
        var params:NSMutableDictionary = NSMutableDictionary()
        
       /* params.setValue(locationQuery, forKey: "address")
        params.setValue("false", forKey: "sensor")
        params.setValue("$region", forKey: "region")*/
        
        let jsonRequest = JSonHelper.new()
        let jsonData = jsonRequest.getJson(searchUrl+postParams,dict: params) as!  NSMutableDictionary
        
        let resultData = jsonData.valueForKey("results") as! NSMutableArray
        let result2 = resultData[0].valueForKey("geometry") as! NSMutableDictionary
        let result3 = result2.valueForKey("location") as! NSMutableDictionary
        
        let lat:Double = result3.valueForKey("lat") as! Double
        let lon:Double = result3.valueForKey("lng") as! Double
        
        centerMap(lat, withLon: lon)
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
        let milesWide = currentDistWideInMeters / 1609.34  // number of meters in a mile
        //println()
        
        //NSLog("Scale in KM:\(Double(currentDistWideInMeters)/1000)")
        
        return Double(currentDistWideInMeters)/1000  //In KM
    }
    
    
    
    func showReviewButtonClick(sender:UIButton) {
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("rateViewController") as! RateViewController
        let index = sender.tag
        NSLog("Visualizzo: \(index)")
        
        let pinArray: NSArray = mainMap.annotations as NSArray
        
        for item in pinArray {
            if( item is PinAnnotation) {
            let itm: PinAnnotation = item as! PinAnnotation
            if (itm.Tag == index) {
                vc.currentTitle = itm.title
                vc.currentDescription = itm.subtitle
                vc.imageLink = itm.ImageLink
                vc.currentRating = itm.Rating
                vc.currentReviewID = itm.ReviewID
                vc.Q1 = itm.Question1
                vc.Q2 = itm.Question2
                vc.Q3 = itm.Question3
                if(locationManager.location != nil) {
                    vc.lastLatitude = locationManager.location.coordinate.latitude
                    vc.lastLongitude = locationManager.location.coordinate.longitude
                }
                vc.delegate = self
                self.presentViewController(vc, animated: true, completion: nil)
                break
            }
            }
        }
    }
    
    func showInfoPanel(annotation: PinAnnotation) {
        
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("ShowReviews") as! ShowReviewViewController
        NSLog("Visualizzo: \(annotation.Tag)")
        
        let pinArray: NSArray = mainMap.annotations as NSArray
        
        for item in pinArray {
            if( item is PinAnnotation) {
                let itm: PinAnnotation = item as! PinAnnotation

                    /*vc.currentTitle = itm.title
                    vc.currentDescription = itm.subtitle
                    vc.imageLink = itm.ImageLink
                    vc.currentRating = itm.Rating
                    vc.currentReviewID = itm.ReviewID
                    vc.Q1 = itm.Question1
                    vc.Q2 = itm.Question2
                    vc.Q3 = itm.Question3
                    if(locationManager.location != nil) {
                        vc.lastLatitude = locationManager.location.coordinate.latitude
                        vc.lastLongitude = locationManager.location.coordinate.longitude
                    }*/
                    vc.pin = annotation
                   // currentAnnotation = annotation
                   // self.performSegueWithIdentifier("showReview", sender: self)
                    self.presentViewController(vc, animated: true, completion: nil)
            }
        }

        
      /*  let infoPanel:UIView = UIView(frame: CGRectMake(136, 8, 400, 200))
        let backImage:UIImageView = UIImageView(frame: infoPanel.bounds)
        let imageInfo:UIImageView = UIImageView(frame: CGRectMake(8, 8, 120, 120))
        let titleLabel:UILabel = UILabel(frame:CGRectMake(136, 8, 256, 20))
        let description:UITextView = UITextView(frame: CGRectMake(136, 37, 255, 99))
        let buttonAddReview:UIButton = UIButton(frame: CGRectMake(8, 144, 108, 46))
        let buttonShowReview:UIButton = UIButton(frame: CGRectMake(280, 144, 112, 46))
        
        buttonAddReview.setTitle("Add Review", forState: UIControlState.Normal)
        buttonShowReview.setTitle("Show Refview", forState: UIControlState.Normal)
        buttonAddReview.titleLabel?.textColor = UIColor.blackColor()
        buttonShowReview.titleLabel?.textColor = UIColor.blackColor()
        buttonAddReview.addTarget(self, action: "showReviewButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonAddReview.tag = Int(annotation.Tag)
        
        imageInfo.layer.cornerRadius = 10
        backImage.image = UIImage(named: "infoBox")
        titleLabel.text = annotation.title
        description.text = annotation.subtitle
        description.backgroundColor = UIColor.clearColor()
        infoPanel.backgroundColor = UIColor.grayColor()
        infoPanel.layer.cornerRadius = 12
        
        infoPanel.addSubview(backImage)
        infoPanel.addSubview(buttonShowReview)
        infoPanel.addSubview(buttonAddReview)
        infoPanel.addSubview(description)
        infoPanel.addSubview(imageInfo)
        infoPanel.addSubview(titleLabel)
        infoPanel.center = self.view.center
        infoPanel.tag = 999
        self.view.addSubview(infoPanel)
        
        ThisImage.contentMode = UIViewContentMode.ScaleAspectFit
        if let checkedUrl = NSURL(string:annotation.ImageLink) {
            downloadImage(checkedUrl,frame: imageInfo)
        }
        */
    }

    
    func sendLongText() {
        
            let filenames = "TextLabel";      //set name here
        
            NSLog("\(filenames)");
            let urlString = "http://localhost:8888/test.php";
            
            let request = NSMutableURLRequest()
            request.URL = NSURL(string: urlString)
            request.HTTPMethod = "POST"
            
            let boundary = "---------------------------14737809831466499882746641449"
        
            let contentType = String(format:"multipart/form-data; boundary=\(boundary)")
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            let body = NSMutableData()
        
            //Block
            body.appendData(String(format:"\r\n--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData(String(format:"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData(filenames.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        
        
            //End
            body.appendData(String(format:"\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
            request.HTTPBody = body
        
            var response: NSURLResponse?
            var error: NSError?
        
            let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
            if let httpResponse = response as? NSHTTPURLResponse {
            println("Response: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode<300
            {
                let responseData = NSString(data: urlData!, encoding: NSUTF8StringEncoding)
                NSLog("\(responseData)")
            //    let jsonData = parseJSON(urlData!)
              //  return jsonData
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
       // testImage.image = getScreenImage()
       // rippleView(testImage)
        currentAnnotation = nil
        
        if (locationManager.location != nil) {
            searchByUserLocation(locationManager.location.coordinate.latitude, lon: locationManager.location.coordinate.longitude, center: true)
        }
        else {
            searchForLocation("Italia", withRadius: 100.0, center: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // searchByUserLocation(locationManager.location.coordinate.latitude, lon: locationManager.location.coordinate.longitude, center: true)
        
       // searchForLocation("Catania", withRadius: zoomLevelForMap(), center: true)
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func setupUI(){
        let tapMapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer()
        tapMapRecognizer.addTarget(self, action: "mapTap:")
        tapMapRecognizer.numberOfTapsRequired = 1
        mainMap.addGestureRecognizer(tapMapRecognizer)
        
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.tintColor            = UIColor.lightGrayColor()
        searchBar.barTintColor         = UIColor.whiteColor()
        searchBar.placeholder          = "Search place here"
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let rightScroll:UISwipeGestureRecognizer = UISwipeGestureRecognizer()
        rightScroll.addTarget(self, action: "swipeMap:")
        rightScroll.direction =  UISwipeGestureRecognizerDirection.Right
        mainMap.addGestureRecognizer(rightScroll)
        
    }
    
    func swipeMap(selector:UISwipeGestureRecognizer) {
        NSLog("Map swiped")
    }
    
    func mapTap(tap:UIGestureRecognizer) {
       // NSLog("Tapped on map")
        
        if let popupView = self.view.viewWithTag(999) {
            popupView.removeFromSuperview()
        }
    }
    
    func searchForLocation(location:String, withRadius radius_:Double, latitude_:Double=0.0, longitude_:Double=0.0, center:Bool) {
        var searchUrl:String = url + "review.php"
        var postParams:String = ""
        
        var radius = radius_
        if(radius < 1) {
            radius = 1
        }
        
        let new_location = location.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var params:NSMutableDictionary = NSMutableDictionary()
        
        if latitude_==0.0 && longitude_==0.0 {
            params.setValue("get_review", forKey: "command")
            params.setValue(new_location, forKey: "address")
            params.setValue((NSString(format: "%.2f", radius) as String), forKey: "radius")
            if (new_location == "") {
                return
            }
        }
        else {
            params.setValue("get_review", forKey: "command")
            params.setValue("\(latitude_)", forKey: "latitude")
            params.setValue("\(longitude_)", forKey: "longitude")
            params.setValue((NSString(format: "%.2f", radius) as String), forKey: "radius")
        }
        
        let jsonRequest = JSonHelper.new()
        let jsonData = jsonRequest.getJson(searchUrl,dict: params) as! NSMutableArray
        var i=0
        mainMap.removeAnnotations(mainMap.annotations)
        var Pins:NSMutableArray = NSMutableArray.new()
        for dict in jsonData {
            let description = dict.valueForKey("description") as? String
            let createdAt = dict.valueForKey("CreatedAt") as? String
            let image = dict.valueForKey("image") as? String
            let latitude = dict.valueForKey("lat") as! NSString
            let longitude = dict.valueForKey("lon") as! NSString
            var rating = dict.valueForKey("rating") as? String
            let title = dict.valueForKey("title") as? String
            let reviewID = dict.valueForKey("id") as! String
            let lat:Double = (latitude  as NSString).doubleValue
            let lon:Double = (longitude as NSString).doubleValue
            let question1:String = dict.valueForKey("question1") as! String
            let question2:String = dict.valueForKey("question2") as! String
            let question3:String = dict.valueForKey("question3") as! String
            var _lat:String = String(format:"{%f,%f}", lat,lon)
            let point = CGPointFromString(_lat)
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
            if rating == nil {
                rating = "0"
            }
            else
            {
                var fullNameArr = rating?.componentsSeparatedByString(".")[0]
                rating = fullNameArr
            }
            let pinPoint = PinAnnotation(coordinate: coordinate, title:title!, subtitle: description!, tag: i,rating: rating!, link: image!, ID: reviewID, Q1: question1, Q2: question2, Q3: question3)
            
            Pins.addObject(pinPoint)
            i = i + 1
        }
        
        if i > 0 {
            mainMap.addAnnotations(Pins as [AnyObject])
            
            if(center) {
                fitAnnotation(Pins)
            }
        }
        
        if(center && latitude_ > 0 && longitude_ > 0) {
        //    if( latitude_ > 0.0 && longitude_ > 0.0) {
            
                centerMap(latitude_, withLon: longitude_)
        //    }
        }
        
        NSLog("Showed pins: \(i)")
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
        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                frame.image = UIImage(data: data!)
            }
        }
    }
    
}

extension ViewController:MKMapViewDelegate {
    
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if let popupView = self.view.viewWithTag(999) {
            popupView.removeFromSuperview()
        }
       // zoomLevelForMap()
        var region:MKCoordinateRegion = mainMap.region  // get the current region
        searchByUserLocation(region.center.latitude, lon: region.center.longitude, center: false)
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        let pinAnnotationView = PinAnnotationView(annotation: annotation, reuseIdentifier: "Points")
        pinAnnotationView.canShowCallout = true
        if (pinAnnotationView.annotation is PinAnnotation) {
            let currAnnotation:PinAnnotation = pinAnnotationView.annotation as! PinAnnotation
        
            pinAnnotationView.disclosureBlock = { NSLog("selected Pin"); self.showInfoPanel(currAnnotation) }
        }
        return pinAnnotationView
    }

    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let rr:PinAnnotationView = view as? PinAnnotationView {
            rr.shrink()
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        if let rr:PinAnnotationView = view as? PinAnnotationView {
            rr.expand()
            if let annotation = view.annotation as? PinAnnotation {
                NSLog("Le tre domande: \(annotation.Question1) - \(annotation.Question2) - \(annotation.Question3)")
            }
        }

    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        //if let annotation = view.annotation as? PinAnnotation {
        //    NSLog("Clicked: \(annotation.Tag)")
        //}
    }
    
}

extension ViewController:CLLocationManagerDelegate {
    
    func locationManager(_manager: CLLocationManager!,didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //    NSLog("User Position: \(locationManager.location.coordinate.latitude)")
        mainMap.showsUserLocation = true
    }
    
}

extension ViewController:UIPopoverPresentationControllerDelegate {
    
}

extension ViewController:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if count(searchBar.text) > 0 {
            searchBar.resignFirstResponder()
            searchBar.endEditing(true)
            getCoordinatesByLocation(searchBar.text)
            searchForLocation(searchBar.text,withRadius: zoomLevelForMap(),center: true)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

