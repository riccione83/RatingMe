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
    
    //let url = "https://ratingme-riccione83.c9.io/"
    let url = "https://ratingme.herokuapp.com/"
    
    let API_newReview = "api/new_review"
    let API_newUser = "api/register_new_user"
    let API_login = "api/login_user"
    let API_showReviews = "api/show_reviews"
    let API_showRatings = "api/show_ratings"
    let API_newRating = "api/new_rating"
    let API_loginWithSocial = "api/login_with_social"
    let API_searchReviews = "api/search_reviews"
    let API_reportReviewAbuse = "api/report_review"
    let API_reportUser = "api/report_user"
    
    let API_getMessages = "api/get_messages"
    let API_deleteMessage = "api/delete_message"
    let API_setMessageReaded = "api/set_message_read"
    let API_setMessageUnread = "api/set_message_unread"
    let API_getNumberOfMessages = "api/get_num_of_messages"
    let API_sendNewMessage = "api/new_message_to_user"
    
    let API_getCategories = "api/get_categories"
    let API_getCategoryImage = "api/get_category_image"
    
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
