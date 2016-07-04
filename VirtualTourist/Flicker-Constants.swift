//
//  Flicker-CONSTANTS.swift
//  VirtualTourist
//
//  Created by Arsalan Akhtar on 11/10/2015.
//  Copyright (c) 2015 Arsalan Akhtar. All rights reserved.
//

import Foundation

extension Flicker {
    
    struct Constants {
        
        // MARK: - URLs
        static let ApiKey = "c3ee17731a8e9ea93237fd20992900df"
        static let SecretKey = "e2e30e4e249ec563"
        static let BaseUrl = "https://api.flickr.com/services/rest/"
    }
    
    struct Resources {
        
        // MARK: - Search
        static let Search = "flickr.photos.search";
        
        // MARK: - Extras
       static let EXTRAS = "url_m"
    }
    
    struct Keys {
        static let METHOD           = "method"
        static let API_KEY          = "api_key"
        static let BBOX             = "bbox"
        static let SAFE_SEARCH      = "safe_search"
        static let FORMAT            = "format"
        static let NO_JSON_CALLBACK =  "nojsoncallback"
        static let EXTRAS =  "extras"
    }
    
    struct Values {
      static   let SAFE_SEARCH = "1"
      static   let DATA_FORMAT = "json"
      static   let NO_JSON_CALLBACK = "1"
      static   let BOUNDING_BOX_HALF_WIDTH = 1.0
      static   let BOUNDING_BOX_HALF_HEIGHT = 1.0
      static   let LAT_MIN = -90.0
      static   let LAT_MAX = 90.0
      static   let LON_MIN = -180.0
      static   let LON_MAX = 180.0
    }    
}