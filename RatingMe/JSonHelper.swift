//
//  JSonHelper.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 19/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit
import Alamofire

public class JSonHelper {
    
    //let url = "http://ratingme-riccione83.c9.io/"
    let url = "https://ratingme.herokuapp.com/"
    
    let API_newReview = "api/new_review"
    let API_newUser = "api/register_new_user"
    let API_login = "api/login_user"
    let API_showReviews = "api/show_reviews"
    let API_showRatings = "api/show_ratings"
    let API_newRating = "api/new_rating"
    let API_loginWithSocial = "api/login_with_social"
    
    
    /*
     * This function is used when we need to pass parameters for example in a PHP page
     * you can pass those parameters via the 'parameters as [String:AnyObject]' use key for data name and value for the object
     */
    func getJson(method:String, apiUrl:String,parameters:[String:AnyObject], completitionHandler: (jsonData: AnyObject?) -> ()) {

        var typeOfRequest = Method.GET
        
        if method == "POST" {
            typeOfRequest = Method.POST
        }
        
        Alamofire.request(typeOfRequest, url + apiUrl , parameters: parameters)
            .responseJSON { response in
                let JSON = response.result.value
                if JSON != nil {
                    completitionHandler(jsonData: JSON as AnyObject?)
                }
                else {
                    completitionHandler(jsonData: "no_connection")
                }
        }
    }
    
  /*  func postJson(apiUrl:String,parameters:[String:AnyObject], completitionHandler: (jsonData: AnyObject?) -> ()) {
        
        Alamofire.request(.POST, url + apiUrl , parameters: parameters)
            .responseJSON { response in
                let JSON = response.result.value
                completitionHandler(jsonData: JSON as AnyObject?)
        }
    }
  */

    
    func uploadWithParameters(apiUrl:String, parameters:[String:AnyObject],image:UIImage?, completitionHandler: (jsonData: Response<AnyObject, NSError>?,error: ErrorType?) -> ()) {
        
        Alamofire.upload(
            .POST,
            url + apiUrl,
            multipartFormData: { multipartFormData in
                
                for (key,value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: key)
                }
                
                if image != nil {
                    let imageData = UIImagePNGRepresentation(image!)
                    multipartFormData.appendBodyPart(data: imageData!, name: "picture", fileName: "Image.jpg", mimeType: "image/jpg")
                }
            },
            encodingCompletion: { encodingResult in
                var error:ErrorType?
                var result: Response<AnyObject, NSError>?
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        result = response
                        completitionHandler(jsonData: result, error: error)
                    }
                case .Failure(let encodingError):
                    error = encodingError
                    completitionHandler(jsonData: result, error: error)
                }
            
            }
        )
    }

}
