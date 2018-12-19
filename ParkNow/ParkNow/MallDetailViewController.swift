//
//  MallDateilsViewController.swift
//  ParkNow
//
//  Created by christy on 18/12/2018.
//  Copyright © 2018 christy. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import Alamofire
import SwiftyJSON


class MallDateilViewController: UIViewController {
    var mallId:String = ""
    var mallName:String = ""
    var latitude:Double = 0
    var longitude:Double = 0
    var address:String = ""
//    var lots:Int = 0
    var realmResults:Results<Mall>?
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var lotsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpMap()
//        self.getData()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpMap(){
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        let regionRadius: CLLocationDistance = 500
        
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
        let pin = MKPointAnnotation()
        
        pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        pin.title = mallName
        pin.subtitle = "Available lots: "
        
        mapView.addAnnotation(pin)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
