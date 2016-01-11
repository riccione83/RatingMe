//
//  ReviewViewController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 01/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Alamofire
import MBProgressHUD

protocol ReviewControllerProtocol {
    func searchByUserLocation(lat:Double,lon:Double, center: Bool)
}

class ReviewViewController: UIViewController {
    
    let jsonRequest = JSonHelper()
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var reviewMap: MKMapView!
    @IBOutlet var reviewTitle: UITextField!
    @IBOutlet var reviewText: UITextView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var textQuestion1: UITextField!
    @IBOutlet var textQuestion2: UITextField!
    @IBOutlet var textQuestion3: UITextField!
    @IBOutlet var thumbImage: UIImageView!
    @IBOutlet var tmbImageButton: UIButton!
    
    let locationManager:CLLocationManager = CLLocationManager()
    var delegate:ReviewControllerProtocol? = nil
    var keyboardWasShowed: Bool = false
    var imagePicker = UIImagePickerController()
    var selectedImage:UIImage? = nil
    
    func selectImageToSend() {
        
        let alert = UIAlertController(title: "Insert image", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Photo Album", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            self.imagePicker.allowsEditing = false
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            self.imagePicker.allowsEditing = false
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func selectImageFromPhotoAlbum() {

    }
    
    @IBAction func selectImage(sender: AnyObject) {
        if thumbImage.image == nil {
            selectImageToSend()
        }
        else
        {
            thumbImage.image = nil
             tmbImageButton.titleLabel?.text = "+"
        }
        
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Sending..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func newReview(title:String, description:String, latitude:String, longitude:String, question1:String="", question2:String="", question3:String="")
    {
        let newTitle = title
        let newDescription = description
        
        let params = [
                            "latitude":latitude,
                            "longitude":longitude,
                            "title":newTitle,
                            "description":newDescription,
                            "question1":question1,
                            "question2":question2,
                            "question3":question3,
                            "user_id":"1",
                            "isAdvertisement":"0",
                            "adImageLink":"0" ]
        
        self.showLoadingHUD()
        jsonRequest.uploadWithParameters(jsonRequest.API_newReview, parameters: params, image: selectedImage) { (jsonData, jsonError) -> () in
            self.hideLoadingHUD()
            if jsonData != nil {
                if jsonData!.result.isSuccess {
                    let serverResponse = jsonData!.result.value as! NSDictionary
                    
                    if let responseMessage = serverResponse["message"] {
                        if (responseMessage as! String) == "success" {
                            if (self.delegate != nil) {
                                self.delegate?.searchByUserLocation(self.locationManager.location!.coordinate.latitude, lon: self.locationManager.location!.coordinate.longitude, center: true)
                            }
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        print(responseMessage)
                        return
                    }
                    else {
                        if let responseMessage = serverResponse["error"] {
                            self.showMessage(responseMessage as! String)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendNewReviewBtnClick(sender: AnyObject) {
        if(locationManager.location != nil) {
            
            let lat = "\(locationManager.location!.coordinate.latitude)"
            let lon = "\(locationManager.location!.coordinate.longitude)"
            
            if(textQuestion1.text != "" && reviewTitle.text != "" && reviewText.text != "" && reviewText.text != "Enter a description") {
                newReview(reviewTitle.text!, description: reviewText.text, latitude: lat, longitude: lon, question1: textQuestion1.text!, question2: textQuestion2.text!, question3: textQuestion3.text!)
            }
            else {
                showMessage("Unable to send this review. Please fill all the requested fields and at least one question.")
            }
        }
        else {
            self.showMessage("Unable to create a new Review. Please enable location services")
        }
    }
    @IBAction func sendNewReview(sender: UIButton) {
        

    }
    
    @IBAction func cancelClickButton(sender: UIButton) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showMessage(message:String) {
        let alert = UIAlertController(title: "RateMe", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func initUI() {
        self.scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, scrollView.bounds.size.height*3)
        var offset: CGPoint = scrollView.contentOffset
        offset.x = 2
        scrollView.contentOffset = offset
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            var offset: CGPoint = scrollView.contentOffset
            offset.x = 2
            scrollView.contentOffset = offset
        }
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
        if !keyboardWasShowed {
            self.view.frame.origin.y -= 160
            keyboardWasShowed = true
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if keyboardWasShowed {
            self.view.frame.origin.y += 160
            keyboardWasShowed = false
        }
    }
    
    func closeKeyboard(touch:UIGestureRecognizer) {
        reviewTitle.resignFirstResponder()
        reviewText.resignFirstResponder()
        textQuestion1.resignFirstResponder()
        textQuestion2.resignFirstResponder()
        textQuestion3.resignFirstResponder()
        self.view.endEditing(true)
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

extension ReviewViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {  //For ImagePicker
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        
        })
        
        //selectedImage = image
        let aspectRatio = image.size.width / image.size.height
        let newHeight = 600 / aspectRatio
        
        UIGraphicsBeginImageContext(CGSizeMake(600, newHeight))
        image.drawInRect(CGRectMake(0, 0, 600, newHeight))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        selectedImage =  scaledImage
        
        thumbImage.image = scaledImage
        
        tmbImageButton.titleLabel?.text = "X"
        
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
