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

class MallDetailViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    var mallId:String = ""
    var mallName:String = ""
    var district:String = ""
    var address:String = ""
    var contact:String = ""
    var poster:String = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    var carparkArr = [Carparks]()
    var realmResults:Results<Mall>?
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        tableView.register(UINib(nibName: "CarparkTableViewCell", bundle: nil), forCellReuseIdentifier: "CarparkTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpMap()
        self.getCarpark()
    }
    
    private func getCarpark(){
        self.carparkArr.removeAll()
        let parameters : Parameters = ["mallId": self.mallId]
        
        Alamofire.request(server + "carpark/getCarpark", method: .post , parameters : parameters ).validate().responseJSON { response in
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
                                chargeOnWeekends: json[index]["chargeOnWeekends"].intValue
                        )
                    )
                        let pin = MKPointAnnotation()
                        
                        pin.coordinate = CLLocationCoordinate2D(latitude: json[index]["latitude"].doubleValue, longitude: json[index]["longitude"].doubleValue)
                        pin.title = json[index]["carparkName"].stringValue
                        pin.subtitle = "Available lots: " + String(json[index]["lots"].intValue)
                        self.mapView.addAnnotation(pin)
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
    }
    

    func setUpMap(){
        let initialLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)

        let regionRadius: CLLocationDistance = 500

        let mallRegion = MKCoordinateRegion(
            center: initialLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)

        self.mapView.setRegion(mallRegion, animated: true)

    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carparkArr.count
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "carparkCell", for: indexPath)
//        cell.textLabel?.text = carparkArr[indexPath.row].carparkName
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarparkTableViewCell", for: indexPath) as! CarparkTableViewCell
        cell.carparkLabel.text = self.carparkArr[indexPath.row].carparkName
        cell.mallLabel.text = self.carparkArr[indexPath.row].mallName
        cell.lotsLabel.text = "\(String(self.carparkArr[indexPath.row].lots))"
        cell.navBtn.tag = indexPath.row
        cell.navBtn.addTarget(self, action: #selector(self.navBtnClicked(_:)), for: .touchUpInside);
        return cell
    }
    
    @IBAction func navBtnClicked(_ sender: Any) {
        let index = (sender as AnyObject).tag
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlStr = "comgooglemaps://?q=\(self.carparkArr[index!].carparkName)&center=\(self.carparkArr[index!].latitude),\(self.carparkArr[index!].longitude)&zoom=14&views=traffic"
            if let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            print("Can't use comgooglemaps://");
        }
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(indexPath.row)
        var msg = "Charge: \nMon-Fri: $" + String(carparkArr[indexPath.row].chargeOnWeekday) +
            " \nSat&Sun: $" + String(carparkArr[indexPath.row].chargeOnWeekends)
        let alertController = UIAlertController(title: "iPark", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)

    }


//    redirect to google map
//    @IBAction func NavBtnClicked(_ sender: Any) {
//
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//            let urlStr = "comgooglemaps://?q=\(self.mallName)&center=\(self.latitude),\(self.longitude)&zoom=14&views=traffic"
//            if let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!){
//                print("Nav System: " + self.mallName);
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//        } else {
//            print("Can't use comgooglemaps://");
//        }
//    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
