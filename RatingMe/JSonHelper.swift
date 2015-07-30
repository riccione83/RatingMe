//
//  JSonHelper.swift
//  JustParkTechnicalTest
//
//  Created by Riccardo Rizzo on 19/06/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class JSonHelper: NSObject {
    
    
    override init() {
       
    }
    
    func getJson(url:String, dict:NSMutableDictionary) -> AnyObject {
        
        let urlString = url
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: urlString)
        request.HTTPMethod = "POST"
        
        let boundary = "---------------------------14737809831466499882746641449"
        
        let contentType = String(format:"multipart/form-data; boundary=\(boundary)")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        for (value,key) in dict {
            NSLog("Value for \(value) = \(key)")
            body.appendData(String(format:"\r\n--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            let str = "Content-Disposition: form-data; name=\"\(value)\"\r\n\r\n"
            
            body.appendData(str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            body.appendData(key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        }
        
        body.appendData(String(format:"\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPBody = body
        
        var response: NSURLResponse?
        var error: NSError?
        
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        if let httpResponse = response as? NSHTTPURLResponse
        {
            println("Response: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode<300
            {
                let responseData = NSString(data: urlData!, encoding: NSUTF8StringEncoding)
             //   NSLog("\(responseData)")
                let jsonData: AnyObject = parseJSON(urlData!)
                return jsonData
            }
        }
        return NSMutableArray.new()
    }
    
 /*   func getJson(urlBase:String,post_params:String) -> AnyObject {  //NSMutableArray
        
        let post:String = post_params
        NSLog(post);
        let url:NSURL = NSURL(string: urlBase)!
        
        let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!;
        let postLength:NSString = NSString(format: "%lu", postData.length)
        let request:NSMutableURLRequest = NSMutableURLRequest();
        request.URL = url
        request.HTTPMethod="POST"
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        
        var response: NSURLResponse?
        var error: NSError?
        
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        if let httpResponse = response as? NSHTTPURLResponse {
            println("Response: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode<300
            {
                let responseData = NSString(data: urlData!, encoding: NSUTF8StringEncoding)
                let jsonData = parseJSON(urlData!)
                return jsonData
            }
        }
        return NSMutableArray.new()
    }*/
    
    func parseJSON(inputData: NSData) -> AnyObject{
        var error: NSError?
        //var boardsDictionary: NSMutableArray = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSMutableArray
        
        var boardsDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error)
        
        return boardsDictionary!
    }
    
    func getJsonData(getUrl: String, completion:(NSDictionary -> Void)) {
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = getUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = getUrl
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                println("Task completed")
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                
                if let jsonResult:NSDictionary = (NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments , error: &err) as? NSDictionary) {
                    
                    //if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                    
                    if(err != nil) {
                        // If there is an error parsing JSON, print it to the console
                        println("JSON Error \(err!.localizedDescription)")
                    }
                    let results: NSDictionary = jsonResult as NSDictionary
                    //completion(jsonResult as NSDictionary)
                    
                     dispatch_async(dispatch_get_main_queue(), {
                        completion(jsonResult as NSDictionary)
                 })
                    
                }
            }) 
            // The task is just an object with all these properties set
            // In order to actually make the web request, we need to "resume"
            task.resume()
        }
    }

    
    
    func getJsonDataForPlace(searchTerm: String, completion:(NSDictionary -> Void)) {
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "https://api.justpark.com/1.1/location/?q=" + searchTerm
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                println("Task completed")
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                
                if let jsonResult:NSDictionary = (NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers , error: &err) as? NSDictionary) {
                    if(err != nil) {
                        // If there is an error parsing JSON, print it to the console
                        println("JSON Error \(err!.localizedDescription)")
                    }
                    let results: NSDictionary = jsonResult as NSDictionary
                    
                     dispatch_async(dispatch_get_main_queue(), {
                            completion(jsonResult as NSDictionary)
                     })
                
                }
            })
            // The task is just an object with all these properties set
            // In order to actually make the web request, we need to "resume"
            task.resume()
        }
    }
    
   
}
