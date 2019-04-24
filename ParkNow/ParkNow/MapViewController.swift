//
//  MapViewController.swift
//  ParkNow
//
//  Created by christy on 22/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift
import MapKit
import CoreLocation

struct Carparks {
    var mallId:String
    var mallName:String
    var carparkId:String
    var carparkName:String
    var longitude: Double
    var latitude: Double
    var lots:Int
    var chargeOnWeekday:Int
    var chargeOnWeekends:Int
    
}

struct Nearest {
    var distance:Int
    var mallId:String
    var mallName:String
    var carparkId:String
    var carparkName:String
    var longitude: Double
    var latitude: Double
    var lots:Int
    var chargeOnWeekday:Int
    var chargeOnWeekends:Int
}

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    var realmResults:Results<Carpark>?
    var carparkArr = [Carparks]()
    var nearestArr = [Nearest]()
    var myLongitude:Double = 0;
    var myLatitude:Double = 0;
    let locationManager = CLLocationManager()
    private var infoWindow = MapMarkerWindow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setUplocationManager()
        tableView.register(UINib(nibName: "CarparkTableViewCell", bundle: nil), forCellReuseIdentifier: "CarparkTableViewCell")
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
        self.carparkArr.removeAll()
        Alamofire.request(server + "carpark/json", method: .get).validate().responseJSON { response in
            print("Car Park info: \(response.result.value)") // response serialization result
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);

                for index in 0..<json.count {
                    self.carparkArr.append(
                        Carparks(
                            mallId: "\(json[index]["mallId"].stringValue)",
                            mallName: "\(json[index]["mallName"].stringValue)",
                            carparkId: "\(json[index]["carparkId"].stringValue)",
                            carparkName: "\(json[index]["carparkName"].stringValue)",
                            longitude: json[index]["longitude"].doubleValue ,
                            latitude: json[index]["latitude"].doubleValue,
                            lots: json[index]["lots"].intValue,
                            chargeOnWeekday: json[index]["chargeOnWeekday"].intValue,
                            chargeOnWeekends: json[index]["chargeOnWeekends"].intValue)
                    )
                }
            self.findNearestCarPark()
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
            self.nearestArr.removeAll()
            let myLocation = CLLocation(latitude: self.myLatitude, longitude: self.myLongitude)
            let regionRadius: CLLocationDistance = 3000
            let coordinateRegion = MKCoordinateRegion(
                center: myLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            self.mapView.setRegion(coordinateRegion, animated: true)
            
            for carpark in carparkArr{
                let carparkLocation = CLLocation(latitude: carpark.latitude , longitude: carpark.longitude)
    
                //Measuring my distance to carpark
                let distance = myLocation.distance(from: carparkLocation) / 1000
                //Display the result in km
                print(String(format: "The distance to \(carpark.mallName) is %.01fkm", distance))
    
                if( distance < 3 ){
                    let pin = MKPointAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude: carpark.latitude , longitude: carpark.longitude)
                    pin.title = carpark.carparkName
                    pin.subtitle = "Available lots: "
                    self.mapView.addAnnotation(pin)
    
                    self.nearestArr.append(
                        Nearest(
                            distance: Int(distance),
                            mallId: "\(String(describing: carpark.mallId))",
                            mallName: "\(String(describing: carpark.mallName))",
                            carparkId: "\(String(describing: carpark.carparkId))",
                            carparkName: "\(String(describing: carpark.carparkName))",
                            longitude: carpark.longitude ,
                            latitude: carpark.latitude,
                            lots: carpark.lots,
                            chargeOnWeekday: carpark.chargeOnWeekday,
                            chargeOnWeekends: carpark.chargeOnWeekends
                            
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
        return self.nearestArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarparkTableViewCell", for: indexPath) as! CarparkTableViewCell
        cell.carparkLabel.text = self.nearestArr[indexPath.row].carparkName
        cell.mallLabel.text = self.nearestArr[indexPath.row].mallName
        cell.lotsLabel.text = "\(String(self.nearestArr[indexPath.row].lots))"
        cell.navBtn.tag = indexPath.row
        cell.navBtn.addTarget(self, action: #selector(self.navBtnClicked(_:)), for: .touchUpInside);
        return cell
    }
    
    @IBAction func navBtnClicked(_ sender: Any) {
        let index = (sender as AnyObject).tag
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlStr = "comgooglemaps://?q=\(self.nearestArr[index!].carparkName)&center=\(self.nearestArr[index!].latitude),\(self.nearestArr[index!].longitude)&zoom=14&views=traffic"
            if let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            print("Can't use comgooglemaps://");
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(indexPath.row)
        var msg = "Charge: \nMon-Fri: $" + String(nearestArr[indexPath.row].chargeOnWeekday) +
            " \nSat&Sun: $" + String(nearestArr[indexPath.row].chargeOnWeekends)
        let alertController = UIAlertController(title: "iPark", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
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
