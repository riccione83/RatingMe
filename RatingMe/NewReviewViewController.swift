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
import Popover

protocol ReviewControllerProtocol {
    func searchByUserLocation(lat:Double,lon:Double, center: Bool)
}

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    @IBOutlet var categoryImage: UIImageView!
    @IBOutlet var middleContainerView: UIView!
    
    
    let locationManager:CLLocationManager = CLLocationManager()
    var categories = NSMutableArray()
    
    var currentSelectedCategory:NSString?
    var delegate:ReviewControllerProtocol? = nil
    var keyboardWasShowed: Bool = false
    var imagePicker = UIImagePickerController()
    var selectedImage:UIImage? = nil
    var userInfo:User = User()
    
    private var popover: Popover!
    private var popoverOptions: [PopoverOption] = [
        .Type(.Up),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    @IBAction func selectCategory(sender: AnyObject) {
        
        var frm: CGRect = sender.frame
        frm.origin.y =  view.frame.maxY
        
        let startPoint = CGPointMake(frm.origin.x, frm.origin.y)
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: view.frame.height/2))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollEnabled = true
        tableView.tag = 999
        
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        self.popover.show(tableView, point: startPoint)
        
    }
    
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
    
    func newReview(title:String, description:String, latitude:String, longitude:String, question1:String="", question2:String="", question3:String="", category: String)
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
            "user_id":userInfo.userID ,
            "isAdvertisement":"0",
            "adImageLink":"0",
            "category" : category]
        
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
            
            if currentSelectedCategory == nil {
                currentSelectedCategory = ""
            }
            
            if userInfo.userLoginType == UserLoginType.Anonymous ||
                userInfo.userLoginType == UserLoginType.Unknow {
                self.showMessage("Sorry login first to create a new Review")
                return
            }
            
            if(textQuestion1.text != "" && reviewTitle.text != "" && reviewText.text != "" && reviewText.text != "Enter a description") {
                newReview(reviewTitle.text!, description: reviewText.text, latitude: lat, longitude: lon, question1: textQuestion1.text!, question2: textQuestion2.text!, question3: textQuestion3.text!, category: "\(currentSelectedCategory!)")
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
        
        
        let category = CategoriesController()
        category.getCategories { (result, errorMessage) -> () in
            self.categories = result
        }
        
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
        touchImage.addTarget(self, action: #selector(ReviewViewController.closeKeyboard(_:)))
        touchImage.numberOfTapsRequired = 1
        backgroundImage.addGestureRecognizer(touchImage)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 999 {
            self.popover.dismiss()
            categoryImage.image = (categories[indexPath.row] as! Category).imageThumb.image
            currentSelectedCategory = (categories[indexPath.row] as! Category).id
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 999 {
            return categories.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = (categories[indexPath.row] as! Category).catDescription as? String
        if (categories[indexPath.row] as! Category).imageThumb.image != nil {
            cell.imageView?.image = resizeImage((categories[indexPath.row] as! Category).imageThumb.image!, newWidth: 25)
        }
        return cell
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
