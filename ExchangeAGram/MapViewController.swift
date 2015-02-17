//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by thomas on 11/18/14.
//  Copyright (c) 2014 thomas. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
                let location = CLLocationCoordinate2D(latitude: 43.009000, longitude: 3.4955948)
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(location, span)
                self.mapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.setCoordinate(location)
                annotation.title = "sdf"
                self.mapView.addAnnotation(annotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
