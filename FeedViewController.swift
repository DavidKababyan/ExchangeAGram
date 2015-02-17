//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by David Kababyan on 2/6/15.
//  Copyright (c) 2015 David Kababyan. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var feedArray:[AnyObject] = []
    var locationManager: CLLocationManager!
    
    @IBOutlet var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
     override func viewDidAppear(animated: Bool) {
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate = (UIApplication .sharedApplication().delegate as AppDelegate)
        
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!
        
        collectionView.reloadData()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("location \(locations)")
    }
    
    // MARK: CollectionView Data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    func collectionView(_collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int{
            return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
            let feedItem = feedArray[indexPath.row] as FeedItem
            
            cell.imageVew.image = UIImage(data: feedItem.image)
            cell.captionLabel.text = feedItem.caption
            
            return cell
    }
    
    //MARK: CollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let feedItem = feedArray[indexPath.row] as FeedItem
        
        var filterVC = FilterViewController()
        filterVC.feedItem = feedItem
        
        self.navigationController?.pushViewController(filterVC, animated: true)
    }

    
    //MARK: UBActions
    
    @IBAction func snapBarButtonItemPressed(sender: UIBarButtonItem) {
        
        //check if the camera is available
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
            
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            
            var alertController = UIAlertController(title: "Error", message: "Your device doesnt have camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    
    @IBAction func profileBarButtonItemPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("toProfileSeg", sender: self)
        
    }
    
    //MARK: UIImagePickerController delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        //grab the original image from the dictionary
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNailData = UIImageJPEGRepresentation(image, 0.3)
        
        //get managed objectContext and entity description to be able to use core data item
        let managedObjectContext = (UIApplication .sharedApplication().delegate as AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        
        //create feedItem
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        feedItem.image = imageData
        feedItem.thumbNail = thumbNailData
        feedItem.caption = "Test Caption"
        feedItem.longitude = self.locationManager.location.coordinate.longitude
        feedItem.latitude = self.locationManager.location.coordinate.latitude
        
        //save to core data
        (UIApplication .sharedApplication().delegate as AppDelegate).saveContext()
        
        //add the item to the feedArray
        feedArray.append(feedItem)
        
        //dismiss the imagePickercontroller
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //reload collectionview
        collectionView.reloadData()
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
}
