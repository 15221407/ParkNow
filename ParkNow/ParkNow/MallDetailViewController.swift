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
    var contact:String = ""
    var spending:Int = 0
     var lots:String?
//    var lots:Int = 0
    var realmResults:Results<Mall>?
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var lotsView: UIView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var contactLabel: UILabel!
    @IBOutlet var offerLabel: UILabel!
    @IBOutlet var offer1Label: UILabel!
    @IBOutlet var offer2Label: UILabel!
    @IBOutlet var offer3Label: UILabel!
    @IBOutlet var lotsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getLots()
    }
    
    func setLabel(){
        addressLabel.text = "Address: " + address
        contactLabel.text = "Contact: " + contact
        offerLabel.text = "Parking Offer:"
        offer1Label.text = "HK$" + String(spending) + " per 1 Hour"
        offer2Label.text = "HK$" + String(spending*2) + " per 2 Hours"
        offer3Label.text = "HK$" + String(spending*3) + " per 3 Hours"
        lotsLabel.text = "Available lots: " + self.lots!
        
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
        pin.subtitle = "Available lots: " + self.lots!
        
       
        
        mapView.addAnnotation(pin)
    }
    
    func getLots() {
        let parameters : Parameters = ["mallName":mallName]
       
        Alamofire.request("http://192.168.0.183:1337/mall/getLots", method: .post, parameters: parameters).responseString { response in
            print("Get Lots: \(response.result.value ?? "No data")")
            switch response.result{
            case .success(let value):
                self.lots = value
            case .failure(let error):
                self.lots = "Fail to return available lots. Try again."
            break
            }
            self.setUpMap()
            self.setLabel()
        }

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
