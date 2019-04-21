//
//  GoParkViewController.swift
//  ParkNow
//
//  Created by christy on 26/1/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift
import MapKit
import CoreLocation


struct Carparks {
    var carparkId:String
    var mallName:String
    var carparkName:String
    var longitude: Double
    var latitude: Double
    
}

struct Nearest {
    var carparkId:String
    var mallName:String
    var carparkName:String
    var distance:Double
}

class GoParkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    var realmResults:Results<Carpark>?
    var carparkArr = [Carparks]()
    var nearestArr = [Nearest]()
    var myLongitude:Double = 0;
    var myLatitude:Double = 0;
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setUplocationManager()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setUpScrollView()
        self.getCarpark()
        self.mapView.isHidden = false;
    }
    
    func setUpScrollView(){
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.scrollView.delegate = self;
        self.tableView.isScrollEnabled = true
        self.scrollView.bounces = false
        self.tableView.bounces = true
    }
    
    func getCarpark(){
        let realm = try! Realm()
        Alamofire.request(server + "carpark/json", method: .get).validate().responseJSON { response in
            print("Car Park info: \(response.result.value)") // response serialization result
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                for index in 0..<json.count {
                    let carpark = Carpark()
                    carpark.mallId = json[index]["mallId"].stringValue
                    carpark.mallName = json[index]["mallName"].stringValue
                    carpark.carparkId = json[index]["carparkId"].stringValue
                    carpark.carparkName = json[index]["carparkName"].stringValue
                    carpark.district = json[index]["district"].stringValue
                    carpark.parkingFee = json[index]["parkingFee"].intValue
                    carpark.peakHourFee = json[index]["peakHourFee"].intValue
                    carpark.longitude = json[index]["longitude"].doubleValue
                    carpark.latitude = json[index]["latitude"].doubleValue
//                    carpark.lots = json[index]["lots"].intValue
                    
                    self.carparkArr.append(
                        Carparks(
                        carparkId: "\(String(describing: carpark.carparkId))",
                        mallName: "\(String(describing: carpark.mallName))",
                        carparkName: "\(String(describing: carpark.carparkName))",
                        longitude: carpark.longitude ,
                        latitude: carpark.latitude)
                    )
                    try! realm.write {
                        realm.add(carpark)
                    }
                }
                self.findNearestCarPark()
                self.realmResults = realm.objects(Carpark.self)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate
            else {
            return
        }
        self.myLatitude = locValue.latitude ;
        self.myLongitude = locValue.longitude ;
        print("My locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func findNearestCarPark(){
        //My location
        let myLocation = CLLocation(latitude: self.myLatitude, longitude: self.myLongitude)
        
        for carpark in carparkArr{
            let carparkLocation = CLLocation(latitude: carpark.latitude , longitude: carpark.longitude)
  
            let regionRadius: CLLocationDistance = 900
            let coordinateRegion = MKCoordinateRegion(
                center: carparkLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
            
            //Measuring my distance to carpark
            let distance = myLocation.distance(from: carparkLocation) / 1000
            //Display the result in km
            print(String(format: "The distance to \(carpark.mallName) is %.01fkm", distance))
            
            if( distance < 3 ){
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: carpark.latitude , longitude: carpark.longitude)
                pin.title = carpark.mallName + "-" + carpark.carparkName
                pin.subtitle = "Available lots: "
                mapView.addAnnotation(pin)
                
                self.nearestArr.append(
                    Nearest(
                        carparkId: "\(String(describing: carpark.carparkId))",
                        mallName: "\(String(describing: carpark.mallName))",
                        carparkName: "\(String(describing: carpark.carparkName))",
                        distance: distance
                    )
                )
            }
        }
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearestArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearestCell", for: indexPath)
        cell.textLabel?.text = String(nearestArr[indexPath.row].mallName)
        return cell
    }

    private func setUplocationManager(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
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
