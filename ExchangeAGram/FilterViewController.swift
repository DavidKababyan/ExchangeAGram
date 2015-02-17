//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by David Kababyan on 2/7/15.
//  Copyright (c) 2015 David Kababyan. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    var feedItem: FeedItem!
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    let context = CIContext(options: nil)
    
    var filterArray:[CIFilter] = []
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let temp = NSTemporaryDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 150)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //letting know the class of cell to the collectionviewcontroller
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(collectionView)
        self.filterArray = self.photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //collectionviewDatasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as FilterCell
        
        
        cell.imageView.image = self.placeHolderImage

        //create other queue
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        //call the new quew
        dispatch_async(filterQueue, { () -> Void in
            let filteredImage = self.getCachedImage(indexPath.row)
            
            //return to the main queue and update the UI
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filteredImage
            })
        })
            
        
        
        return cell
    }
    
    //collectionview delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.createUIAlertController(indexPath)
        
    }
    
    
    
    //Helper
    
    func photoFilters () -> [CIFilter] {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControl = CIFilter(name: "CIColorControls")
        colorControl.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControl, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
        
    }
    
    //UIAlertController helpers
    
    func createUIAlertController (indexPath: NSIndexPath) {
        
        let alert = UIAlertController(title: "Photo Option", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add caption"
            textField.secureTextEntry = false
        }
        
        let textField = alert.textFields![0] as UITextField
        
        
        let photoAction = UIAlertAction(title: "Post photo to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            
            var text = textField.text

            self.shareToFacebook(indexPath)
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        
        alert.addAction(saveFilterAction)
        
        
        let cancelAction = UIAlertAction(title: "Select another filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            
            
        }
        
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveFilterToCoreData (indexPath: NSIndexPath, caption: NSString) {
        
        let filteredImage = self.filteredImageFromImage(feedItem.image, filter: filterArray[indexPath.row])
        let filteredImageData = UIImageJPEGRepresentation(filteredImage, 1.0)
        let thumbnailData = UIImageJPEGRepresentation(filteredImage, 0.3)
        
        feedItem.image = filteredImageData
        feedItem.thumbNail = thumbnailData
        feedItem.caption = caption
        
        (UIApplication .sharedApplication().delegate as AppDelegate).saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func shareToFacebook (indexPath: NSIndexPath) {
        let filteredImage = self.filteredImageFromImage(feedItem.image, filter: filterArray[indexPath.row])
        
        let photos:NSArray = [filteredImage]
        var params = FBPhotoParams()
        params.photos = photos
        
        //the call, result and error are just var names, we can use anithyng as the var names
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            
            if result != nil {
                println(result)
            }else {
                println(error)
            }
            
        }

    }
    
    
    //CacheImage
    
    func cacheImage (imageNumber: Int) {
        let fileName = "\(imageNumber)"
        let uniquePath = temp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            
            let data = self.feedItem.thumbNail
            let filter = self.filterArray[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    
    func getCachedImage (imageNumber: Int) -> UIImage {
        
        let fileName = "\(imageNumber)"
        let uniquePath = temp.stringByAppendingPathComponent(fileName)
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
        
    }
    
}
