//
//  JSonHelper.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 19/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class JSonHelper {
    
    /*
    * Use this to get a Json from a url.
    * Return the Dictionary with Json data and a null NSError or an empty NSDictionary with a NSError filled
    */
    func getJsonData(getUrl: String, completion:(NSDictionary,NSError?) -> ()) {
        
        // Now escape anything else that isn't URL-friendly
        if let _ = getUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = getUrl
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                //Task is complete. Let's check is there is some error
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(NSDictionary(), error)
                    })
                }

                do {
                
                    let err: NSError? = nil
                    
                    if let jsonResult:NSDictionary = try (NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments ) as? NSDictionary) {
                    
                        if(err != nil) {
                        // If there is an error parsing JSON, return the error state
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                completion(NSDictionary(), err)
                            })
                        }
                        let results: NSDictionary = jsonResult as NSDictionary
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(jsonResult as NSDictionary, nil)
                        })
                    }
                }
                catch _ {
                    
                }
            })
            // The task is just an object with all these properties set
            // In order to actually make the web request, we need to "resume"
            task.resume()
        }
    }
    
    
    /*
     * This function is used when we need to pass parameters for example in a PHP page
     * you can pass those parameters via the 'dict' Dictionary use key for data name and value for the object
     */
    func getJson(url:String, dict:NSMutableDictionary) throws -> AnyObject {
        
        let urlString = url
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: urlString)
        request.HTTPMethod = "POST"
        
        let boundary = "---------------------------14737809831466499882746641449"
        
        let contentType = String(format:"multipart/form-data; boundary=\(boundary)")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        for (value,key) in dict {
            //NSLog("Value for \(value) = \(key)")
            body.appendData(String(format:"\r\n--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            let str = "Content-Disposition: form-data; name=\"\(value)\"\r\n\r\n"
            
            body.appendData(str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData(key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        }
        
        body.appendData(String(format:"\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPBody = body
        
        var response: NSURLResponse?
        
        let urlData: NSData?
      //  do
      //  {
           urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
      /*  }
        catch _ {
            urlData = nil
        }
        */
        
        if let httpResponse = response as? NSHTTPURLResponse
        {
            print("Response: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode<300
            {
              //  let responseData = NSString(data: urlData!, encoding: NSUTF8StringEncoding)
                let jsonData: AnyObject = parseJSON(urlData!)
                return jsonData
            }
        }
        return NSMutableArray()
    }
    
    
    func parseJSON(inputData: NSData) -> AnyObject{
        var error: NSError?
        let boardsDictionary: AnyObject = try! NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers)
        return boardsDictionary
    }
    
    

}
