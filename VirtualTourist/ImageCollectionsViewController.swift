//
//  ImageCollectionsViewController.swift
//  VirtualTourist
//
//  Created by Arsalan Akhtar on 11/10/2015.
//  Copyright (c) 2015 Arsalan Akhtar. All rights reserved.
//

import UIKit
import MapKit

import CoreData

class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate
{
    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var imageCollectionController: UICollectionView!
    
    var pin : Location!
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.

    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    

    @IBOutlet weak var bottomButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            // Step 2: Perform the fetch
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        // Step 6: Set the delegate to this view controller
        fetchedResultsController.delegate = self
        
        imageCollectionController.delegate = self
    }

    
    
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    
    if pin.photos.isEmpty {
        
            downloadAndUpdate()
        
         }

    setMapRegion()
}
    

func downloadAndUpdate()
    {
         self.refreshButton.enabled = false
        
        Flicker.sharedInstance().getImages(pin.latitude.doubleValue, lon: pin.longitude.doubleValue) {
                
               success , result, errorString  in
            
                if  success
                {
                
                    for dictionary in result! {
                    
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            let photo = Photos(dictionary: dictionary, context: self.sharedContext)
                            
                            photo.pin = self.pin
                        }

                        
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.saveContext()
                    
                    }
            } else {
                print(errorString)
            }
        }
    
    }
    
    
    

    
    
// MARK: - Core Data Convenience

lazy var sharedContext: NSManagedObjectContext =  {
    return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()

func saveContext() {
    CoreDataStackManager.sharedInstance().saveContext()
}


// Step 1: This would be a nice place to paste the lazy fetchedResultsController
lazy var fetchedResultsController: NSFetchedResultsController = {
    
    let fetchRequest = NSFetchRequest(entityName: "Photos")
    fetchRequest.sortDescriptors = []
    fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController.delegate = self
    
    return fetchedResultsController
    
    }()
    


    
    // MARK: - Configure Cell
    
    func configureCell(cell: ImageCell, atIndexPath indexPath: NSIndexPath) {
        
        let image = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photos
    
        var posterImage : UIImage?
      
        // Set the Movie Poster Image
        cell.indicatorDownloading.stopAnimating()
        cell.indicatorDownloading.hidden = true
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.alpha = 0.5
        } else {
            cell.alpha = 1.0
        }
        
        if image.imageURL == nil || image.imageURL == ""
        {
            posterImage = UIImage(named:"flickerNoImage")
            
        } else if image.image != nil {
            posterImage = image.image
           
        }
            
        else { // This is the interesting case. The movie has an image name, but it is not downloaded yet.
            
            // This first line returns a string representing the second to the smallest size that TheMovieDB serves up
            cell.indicatorDownloading.startAnimating()
            cell.indicatorDownloading.hidden = false
            // Start the task that will eventually download the image
            let task = Flicker.sharedInstance().taskForImageWithSize("", filePath: image.imageURL!) { data, error in
                
                if let error = error {
                    print("Poster download error: \(error.localizedDescription)")
                }
                
                if let data = data {
                    // Craete the image
                    let imageByData = UIImage(data: data)
                    
                    
                    
                    // update the cell later, on the main thread
                    
                    dispatch_async(dispatch_get_main_queue()) {
                    
                    // update the model, so that the infrmation gets cashed
                    image.image = imageByData
//                    self.imageCollectionController.reloadItemsAtIndexPaths([indexPath])
               
                    cell.imagePanel!.image = imageByData
                    cell.indicatorDownloading.stopAnimating()
                    cell.indicatorDownloading.hidden = true
                    
                    }
                
                }
                
            }
            cell.taskToCancelifCellIsReused = task
        }
        
        cell.imagePanel!.image = posterImage
    }


    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
       
       return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        
        print("number Of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCellIdentifier", forIndexPath: indexPath) as! ImageCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }

        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        // And update the buttom button
        updateBottomButton()
       
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            refreshButton.title = "Remove Selected Photo"
        } else {
            refreshButton.title = "Refresh Photos"
        }
    }
    
    func deleteSelectedPhotos() {
        var photoToDelete = [Photos]()
        
        for indexPath in selectedIndexes {
            photoToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photos)
        }
        
        for photo in photoToDelete {
            sharedContext.deleteObject(photo)
            if photo.imageURL != nil {
                Flicker.Caches.imageCache.clearImage(photo.id)
            }
        }
        
        selectedIndexes = [NSIndexPath]()
        
        updateBottomButton()
    }

    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
    
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()

        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func  controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            
        break
        
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        

        imageCollectionController.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.imageCollectionController.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.imageCollectionController.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.imageCollectionController.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: { done in
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshButton.enabled = true
                })
        })

        
        
    }

    @IBAction func refreshImages(sender: AnyObject) {
      
        if (selectedIndexes.count > 0)
        {
        
            deleteSelectedPhotos()
        
        }
        else
        {
            
            if let photos = self.fetchedResultsController.fetchedObjects as? [Photos] {
                for photo in photos {
                    
                    if photo.imageURL != nil {
                        Flicker.Caches.imageCache.clearImage(photo.id)
                    }
                    self.sharedContext.deleteObject(photo)
                }
            }
            downloadAndUpdate()

        }
        
    }
    
     func setMapRegion() {
      
        
        let location = CLLocationCoordinate2D(
            latitude: pin.latitude.doubleValue,
            longitude: pin.longitude.doubleValue
        )
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        map.addAnnotation(annotation)
    }
}
