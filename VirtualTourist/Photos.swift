//
//  Images.swift
//  VirtualTourist
//
//  Created by Arsalan Akhtar on 05/10/2015.
//  Copyright (c) 2015 Arsalan Akhtar. All rights reserved.
//

import UIKit
// 1. Import CoreData
import CoreData

// 2. Make Photos available to Objective-C code
@objc(Photos)

class Photos : NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var imageURL:String?
    @NSManaged var pin: Location?
    
    struct Keys {
        static let Id = "id"
        static let Title = "title"
        static let ImageURL = "url_m"
        static let Pin = "pin"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
       
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        title = dictionary[Keys.Title] as! String
        
        imageURL = dictionary[Keys.ImageURL] as? String
        
        id = dictionary[Keys.Id] as! String
        
    }
    
    var image: UIImage? {
        
        get {
            return Flicker.Caches.imageCache.imageWithIdentifier(id)
        }
        
        set {
            if imageURL != nil {
            Flicker.Caches.imageCache.storeImage(newValue, withIdentifier: id)
            }
        }
    }
    
}