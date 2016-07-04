//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Arsalan Akhtar on 04/10/2015.
//  Copyright (c) 2015 Arsalan Akhtar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TouristMapViewController: UIViewController,MKMapViewDelegate,NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var editModeNotificationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var editMode:Bool = false
    
    var pins = [Location]()
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func fetchAllActors() -> [Location] {
        let error: NSErrorPointer = nil
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Location")
        
        // Execute the Fetch Request
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            results = nil
        }
        
        // Check for Errors
        if error != nil {
            print("Error in fectchAllActors(): \(error)")
        }
        
        // Return the results, cast to an array of Person objects
        return results as! [Location]
    }

    func generateMap()
    {
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [CustomAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        print(pins.count)
        
        
        for var index = 0; index < pins.count; ++index {
            
            
            let dictionary = pins[index]
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = dictionary.latitude as Double
            let long = dictionary.longitude as Double
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = CustomAnnotation()
            annotation.tag = index;
            annotation.coordinate = coordinate
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)

        }
       
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        uilgr.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(uilgr)
        mapView.delegate = self
        
        pins = fetchAllActors()
        
        generateMap()
        
        self.title = "Virtual Tourist"
        
        /* Create and set the logout button */
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editButtonTouchUp:")
        
        editModeNotificationLabel.hidden = true
        
    }
    
    func editButtonTouchUp(button:UIBarButtonItem) {
    
       
        if (editMode) {
        editMode = false
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editButtonTouchUp:")
        editModeNotificationLabel.hidden = true
            
        }else{
        editMode = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "editButtonTouchUp:")
        editModeNotificationLabel.hidden = false
        }
    }
    

    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = CustomAnnotation()
            annotation.coordinate = newCoordinates
            
            annotation.tag = pins.count
            
            mapView.addAnnotation(annotation)
            
            let dictionary: [String : AnyObject] = [
                Location.Keys.Longitude : newCoordinates.longitude,
                Location.Keys.Latitude : newCoordinates.latitude
            ]
          
            let locationToBeAdded = Location(dictionary: dictionary, context: sharedContext)
            self.pins.append(locationToBeAdded)
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            
        }
    }

    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        let customAnnotation = annotation as! CustomAnnotation
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        }
        else {
            pinView!.annotation = annotation
        }
        
        pinView?.tag = customAnnotation.tag
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps.
    func mapView(_mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        
        let indexOfAnnotation = view.tag
        let location = self.pins[indexOfAnnotation] as Location
        
        print("Lat:\(location.latitude) Long:\(location.longitude) \n", terminator: "")
        print("Lat:\(view.annotation!.coordinate.latitude) Long:\(view.annotation!.coordinate.longitude) \n", terminator: "")
        
        
        
        if(editMode)
        {
            _mapView.removeAnnotation(view.annotation!)
        
             sharedContext.deleteObject(location)
            
            self.pins.removeAtIndex(indexOfAnnotation)
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
        else
        {
            let controller =
            storyboard!.instantiateViewControllerWithIdentifier("ImageCollectionViewController") as! ImageCollectionViewController
            // Similar to the method above
           
            controller.pin = location
            
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

