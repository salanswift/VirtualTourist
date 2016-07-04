//
//  Location.swift
//  VirtualTourist
//
//  Created by Arsalan Akhtar on 05/10/2015.
//  Copyright (c) 2015 Arsalan Akhtar. All rights reserved.
//

// 1. Import CoreData
import CoreData

// 2. Make Person available to Objective-C code
@objc(Location)

// 3. Make Person a subclass of NSManagedObject
class Location : NSManagedObject {
    
    
    
    // 4. We are promoting these four from simple properties, to Core Data attributes
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos:[Photos]
    
    struct Keys {
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let Images = "images"
        static let ID = "id"
    }

    
    // 5. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    * 6. The two argument init method
    *
    * The Two argument Init method. The method has two goals:
    *  - insert the new Person into a Core Data Managed Object Context
    *  - initialze the Person's properties from a dictionary
    */
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Person" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Person class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        longitude = dictionary[Keys.Longitude] as! Double
        latitude = dictionary[Keys.Latitude] as! Double
        
    }
}