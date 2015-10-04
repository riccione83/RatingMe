//
//  ReviewViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit

protocol ReviewControllerProtocol {
    func searchByUserLocation(lat:Double,lon:Double, center: Bool)
}

class ReviewViewController: UIViewController {

    @IBOutlet var reviewMap: MKMapView!
    @IBOutlet var reviewTitle: UITextField!
    @IBOutlet var reviewText: UITextView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var textQuestion1: UITextField!
    @IBOutlet var textQuestion2: UITextField!
    @IBOutlet var textQuestion3: UITextField!
    
    let locationManager:CLLocationManager = CLLocationManager()
    var delegate:ReviewControllerProtocol? = nil
    
    //let url = "http://localhost:8888/rating/"
    let url = "http://www.riccardorizzo.eu/rating/"
    
    func newReview(title:String, description:String, latitude:String, longitude:String, question1:String="", question2:String="", question3:String="") {
        
        var newTitle = title
        var newDescription = description
        var searchUrl:String = url + "review.php"
        var params:NSMutableDictionary = NSMutableDictionary()
        
        params.setValue("set_review", forKey: "command")
        params.setValue(latitude, forKey: "latitude")
        params.setValue(longitude, forKey: "longitude")
        params.setValue(newTitle, forKey: "title")
        params.setValue(newDescription, forKey: "description")
        params.setValue("1", forKey: "user_id")
        params.setValue(question1, forKey: "question1")
        params.setValue(question2, forKey: "question2")
        params.setValue(question3, forKey: "question3")
        
        let jsonData:AnyObject?
        
        do {
            let jsonRequest = JSonHelper()
        
            jsonData = try jsonRequest.getJson(searchUrl, dict: params)
        }
        catch {
            jsonData = nil
        }
        NSLog("\(jsonData)")
        if (jsonData is NSMutableDictionary) {
            if (jsonData!.valueForKey("message") != nil) {
                NSLog("\(jsonData)")
                if (delegate != nil) {
                    delegate?.searchByUserLocation(locationManager.location!.coordinate.latitude, lon: locationManager.location!.coordinate.longitude, center: true)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                let error_str:String = jsonData!.valueForKey("error") as! String
                NSLog("\(error_str)")
            }
        }
    }
    
    @IBAction func sendNewReview(sender: UIButton) {
        
        let lat = "\(locationManager.location!.coordinate.latitude)"
        let lon = "\(locationManager.location!.coordinate.longitude)"
        
        if(textQuestion1.text != "" && reviewTitle.text != "" && reviewText.text != "" && reviewText.text != "Enter a description") {
            newReview(reviewTitle.text!, description: reviewText.text, latitude: lat, longitude: lon, question1: textQuestion1.text!, question2: textQuestion2.text!, question3: textQuestion3.text!)
        }
        else {
            showMessage("Impossibile inviare la recensione. E' necessario compilare tutti i campi e almeno una domanda.")
        }
    }
    
    @IBAction func cancelClickButton(sender: UIButton) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showMessage(message:String) {
        let alert = UIAlertController(title: "RateMe", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func viewDidAppear(animated: Bool) {
        
        let touchImage: UITapGestureRecognizer = UITapGestureRecognizer()
        touchImage.addTarget(self, action: "closeKeyboard:")
        touchImage.numberOfTapsRequired = 1
        backgroundImage.addGestureRecognizer(touchImage)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 160
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 160
    }
    
    func closeKeyboard(touch:UIGestureRecognizer) {
        reviewTitle.resignFirstResponder()
        reviewText.resignFirstResponder()
        textQuestion1.resignFirstResponder()
        textQuestion2.resignFirstResponder()
        textQuestion3.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMap(lat: Double, withLon lon: Double) {
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        reviewMap.setRegion(region, animated: true)
    }
    
}

extension ReviewViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if reviewText.text == "Enter a description" {
            reviewText.text = ""
            reviewText.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if reviewText.text.characters.count == 0 {
            reviewText.text = "Enter a description"
            reviewText.textColor = UIColor.lightGrayColor()
            reviewText.resignFirstResponder()
        }
    }
    
}

extension ReviewViewController: MKMapViewDelegate {
    
}

extension ReviewViewController:CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerMap(locationManager.location!.coordinate.latitude, withLon: locationManager.location!.coordinate.longitude)
        reviewMap.showsUserLocation = true
    }
}
