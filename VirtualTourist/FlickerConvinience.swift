//
//  FlickerConvinience.swift
//  VirtualTourist
//
//  Created by Arsalan Akhtar on 01/11/2015.
//  Copyright © 2015 Arsalan Akhtar. All rights reserved.
//
import Foundation
import UIKit

extension Flicker
{
    
    func getImages(lat:Double,lon:Double, completionHandler:(success:Bool, result:[[String: AnyObject]]?, errorString:String?) -> Void) {
 
        
    let parameters = [
        Flicker.Keys.METHOD : Flicker.Resources.Search,
        Flicker.Keys.API_KEY : Flicker.Constants.ApiKey,
        
        Flicker.Keys.BBOX : createBoundingBoxString(lat , lon: lon),
        
        Flicker.Keys.SAFE_SEARCH : Flicker.Values.SAFE_SEARCH,
        Flicker.Keys.EXTRAS : Flicker.Resources.EXTRAS,
        Flicker.Keys.FORMAT : Flicker.Values.DATA_FORMAT,
        Flicker.Keys.NO_JSON_CALLBACK : Flicker.Values.NO_JSON_CALLBACK
        ]
    
    Flicker.sharedInstance().taskForResource("", parameters: parameters){  JSONResult, error  in
        
    if let _ = error
                {
    
        completionHandler(success: false, result: nil, errorString: "Can not find photos for location")
                    
                }
        else
    
    {
    
    if let photosDictionary = JSONResult.valueForKey("photos") as? [String : AnyObject]
    
        {
    
    if let totalPages = photosDictionary["pages"] as? Int
            {
    
    /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
    let pageLimit = min(totalPages, 40)
    let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
        
        self.getImageFromFlickrBySearchWithPage(parameters, pageNumber: randomPage, completionHandler:completionHandler)
    
        }
    
        else
    
        {
        
            
            completionHandler(success: false, result: nil, errorString: "Cant find key 'pages'")
            
        
        }
    
            
            }
        
        else
        
                {
    
    let error = NSError(domain: "Image for Location Parsing. Cant find Location in \(JSONResult)", code: 0, userInfo: nil)
    print(error)
                 completionHandler(success: false, result: nil, errorString: error.localizedDescription)
                    
                }
        
            }
        }


    }

 private func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int,
    
    completionHandler:(success:Bool, result:[[String: AnyObject]]?, errorString:String?) -> Void) {
        
        /* Add the page to the method's arguments */
        var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber
        withPageDictionary["per_page"] = 30
        
        let task = Flicker.sharedInstance().taskForResource("", parameters: withPageDictionary) {
            JSONResult, downloadError in
            
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                var _: NSError? = nil
                
                let parsedResult = JSONResult as! NSDictionary
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject]
                {
                    
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    if totalPhotosVal > 0 {
                        
                        let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]
                        
                         completionHandler(success: true, result: photosArray, errorString: nil)
                        
                    } else {
                
                         completionHandler(success: false, result: nil, errorString: "No Photos Found")
                        
                    }
                }
                else {
                    print(" in \(parsedResult)")
                    completionHandler(success: false, result: nil, errorString: "Cant find key 'photos'")
                }
            }
        }
        
        task.resume()
    }

    
    
  private  func createBoundingBoxString(lat:Double, lon: Double) -> String {
        
        let latitude = lat
        let longitude = lon
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Flicker.Values.BOUNDING_BOX_HALF_WIDTH, Flicker.Values.LON_MIN)
        let bottom_left_lat = max(latitude - Flicker.Values.BOUNDING_BOX_HALF_HEIGHT, Flicker.Values.LAT_MIN)
        let top_right_lon = min(longitude + Flicker.Values.BOUNDING_BOX_HALF_HEIGHT, Flicker.Values.LON_MAX)
        let top_right_lat = min(latitude + Flicker.Values.BOUNDING_BOX_HALF_HEIGHT, Flicker.Values.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
}

