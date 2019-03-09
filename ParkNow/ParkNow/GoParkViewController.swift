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

class GoParkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    var realmResults:Results<Mall>?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
//        self.setUpScrollView()
        self.findNearestCarPark()
    }
    
    func setUpScrollView(){
        tableView.delegate = self;
        tableView.dataSource = self;
        scrollView.delegate = self;
        self.tableView.isScrollEnabled = true
        self.scrollView.bounces = false
        self.tableView.bounces = true
    }
    
    func getDatafromDB(){
        let realm = try! Realm()
        let url = server + "mall/json"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            print("Car Park info: \(response.result.value)") // response serialization result
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                for index in 0..<json.count {
                    let mall = Mall()
                    mall.mallId = json[index]["id"].stringValue
                    mall.name = json[index]["name"].stringValue
                    mall.district = json[index]["district"].stringValue
                    mall.address = json[index]["address"].stringValue
                    mall.parkingFee = json[index]["parkingFee"].stringValue
                    mall.spending = json[index]["spending"].intValue
                    mall.longitude = json[index]["longitude"].doubleValue
                    mall.latitude = json[index]["latitude"].doubleValue
                    try! realm.write {
                        realm.add(mall)
                    }
                }
                self.realmResults = realm.objects(Mall.self)
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
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func findNearestCarPark(){
        
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
    
 
    
    
    func setUpMap(){
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearestCell", for: indexPath)
        cell.textLabel?.text = "Row: \(indexPath.row+1)"
        return cell
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
