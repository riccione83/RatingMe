//
//  CategoriesController.swift
//  RatingMe
//
//  Created by Riccardo Rizzo on 27/02/16.
//  Copyright © 2016 Riccardo Rizzo. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class CategoriesController: NSObject {
    let jsonRequest:JSonHelper = JSonHelper()
    
    
    func downloadImage(url:NSURL, frame:CustomImageView) {
        
        let downloader:SDWebImageDownloader = SDWebImageDownloader.sharedDownloader()
        frame.progressIndicatorView.drawCustom(1)
        
        downloader.downloadImageWithURL(url, options: SDWebImageDownloaderOptions.AllowInvalidSSLCertificates, progress: { (receivedSize, expectedSize) -> Void in
            if receivedSize > 0 && expectedSize > 0 {
                let received:Float = ((Float(receivedSize)*100.0)/Float(expectedSize))/100.0
                frame.updateProgress(CGFloat(receivedSize), expectedSize: CGFloat(expectedSize))
                print("=>",received,expectedSize)
            }
            })
            { (image, data, error, finished) -> Void in  //Download finished
                if ((image != nil) && finished == true) {
                    frame.image = image
                    frame.revealImage()
                }
        }
    }
    
    func getImageForCategory(category:Category, frame:CustomImageView) {
        
        if let checkedUrl = NSURL(string: "\(jsonRequest.url)\(jsonRequest.API_getCategoryImage)?id=\(category.id!)") {
            downloadImage(checkedUrl,frame: frame)
        }
    }
    
    func getCategories(completitionHandler:(result:NSMutableArray,errorMessage:String) ->()) {
        
        let params = [" ":" "]
        
        jsonRequest.getJson("GET", apiUrl: jsonRequest.API_getCategories, parameters: params) { (jsonData) -> () in
            
            let categories = NSMutableArray()
            
            if jsonData == nil {
                completitionHandler(result: NSMutableArray(),errorMessage: "No connection")
            }
            let json = JSON(jsonData!)
            
            if let message = json[0]["error"].string {
              //  print(message)
                completitionHandler(result: NSMutableArray(),errorMessage: message)
            }
            
            for (_,subJson):(String, JSON) in json {
                let category = Category(description: subJson["description"].string!, id: "\(subJson["id"].int!)", image: subJson["image"].string!)
                self.getImageForCategory(category, frame: category.imageThumb)
                categories.addObject(category)
            }
            completitionHandler(result:categories, errorMessage: "")
        }

    }

}
