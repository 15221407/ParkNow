//
//  MyRecordTableViewController.swift
//  ParkNow
//
//  Created by christy on 28/3/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift




class MyRecordTableViewController: UITableViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var shoppingRealmResults:Results<ShoppingRecord>?
    var pointRealmResults:Results<PointRecord>?
    var parkingRealmResults:Results<ParkingRecord>?
    var underlineBar = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.segmentedControl.selectedSegmentIndex = 0
        self.registerNib();
        self.setSegmentedControlStyle()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(UserDefaults.standard.string(forKey: "username") != nil){
//            self.getShoppingRecord();
            self.getPointRecord();
//            self.getParkingRecord();
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setSegmentedControlStyle(){
        // Add lines below selectedSegmentIndex
        self.segmentedControl.backgroundColor = .clear
        self.segmentedControl.tintColor = .clear
        
        // Add lines below the segmented control's tintColor
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20),
            NSAttributedString.Key.foregroundColor: UIColor.orange
            ], for: .selected)
        
//        
//        underlineBar.translatesAutoresizingMaskIntoConstraints = false // false since we are using auto layout constraints
//        underlineBar.backgroundColor = UIColor.orange
//        view.addSubview(underlineBar)
//        
//        underlineBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
//        underlineBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
//        underlineBar.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)).isActive = true
//        

    }

    private func registerNib(){
            tableView.register(UINib(nibName: "PointTableViewCell", bundle: nil), forCellReuseIdentifier: "PointTableViewCell")
            tableView.register(UINib(nibName: "ShoppingTableViewCell", bundle: nil), forCellReuseIdentifier: "ShoppingTableViewCell")
            tableView.register(UINib(nibName: "ParkingTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingTableViewCell")
    }
    
    private func getShoppingRecord(){
        let realm = try! Realm()
        Alamofire.request(server + "shoppingRecord/json", method: .get).validate().responseJSON { response in
            print("Shopping Record: \(response.result.value)") // response serialization resul
            switch response.result {
                
            case .success(let value):
                let json:JSON = JSON(value);
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                for index in 0..<json.count {
                    let shopping = ShoppingRecord()
                    shopping.mallName = json[index]["mallName"].stringValue
                    shopping.shopName = json[index]["shopName"].stringValue
                    print(shopping.shopName)
                    shopping.consumption = json[index]["consumption"].stringValue
                    shopping.point = json[index]["gainedPoint"].stringValue
                    shopping.addAt = json[index]["addAt"].stringValue
                    try! realm.write {
                        realm.add(shopping)
                    }
                }
                self.shoppingRealmResults = realm.objects(ShoppingRecord.self)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getPointRecord(){
        
        let realm = try! Realm()
        Alamofire.request(server + "pointRecord/json", method: .get).validate().responseJSON { response in
            print("Point Record: \(response.result.value)") // response serialization resul
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                for index in 0..<json.count {
                    let point = PointRecord()
                    point.mallName = json[index]["mallName"].stringValue
                    point.type = json[index]["type"].stringValue
                    point.amount = json[index]["amount"].intValue
                    point.actionAt = json[index]["actionAt"].stringValue
                    try! realm.write {
                        realm.add(point)
                    }
                }
                self.pointRealmResults = realm.objects(PointRecord.self)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getParkingRecord(){
        let realm = try! Realm()
        Alamofire.request(server + "parkingRecord/json", method: .get).validate().responseJSON { response in
            print("Shopping Record: \(response.result.value)") // response serialization resul
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                for index in 0..<json.count {
                    let parking = ParkingRecord()
                    parking.mallName = json[index]["mallName"].stringValue
                    parking.carparkName = json[index]["carparkName"].stringValue
                    parking.enterAt = json[index]["enterAt"].stringValue
                    parking.leaveAt = json[index]["leaveAt"].stringValue
                    parking.licensePlate = json[index]["licensePlate"].stringValue
                    try! realm.write {
                        realm.add(parking)
                    }
                }
                self.parkingRealmResults = realm.objects(ParkingRecord.self)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(self.segmentedControl.selectedSegmentIndex)
        {
            case 0:
                if let r = self.pointRealmResults {
                    print("point")
                    print(r.count)
                    return r.count
                } else {
                    return 0
                }
            case 1:
                if let r = self.shoppingRealmResults {
                     print("shopping")
                    print(r.count)
                    return r.count
                } else {
                    return 0
                }
            case 2:
                if let r = self.parkingRealmResults {
                    print("parking")
                    print(r.count)
                    return r.count
                } else {
                    return 0
                }
            
            default:
                break
        }
            return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        switch(self.segmentedControl.selectedSegmentIndex)
        {
        case 0:
            let myCell = tableView.dequeueReusableCell(withIdentifier: "PointTableViewCell", for: indexPath) as!PointTableViewCell
            myCell.dateLabel.text = getDate(dateString:self.pointRealmResults![indexPath.row].actionAt!)
//            myCell.typeImage.text = self.pointRealmResults?[indexPath.row].mallName
            myCell.mallLabel.text = self.pointRealmResults?[indexPath.row].mallName
            if(self.pointRealmResults![indexPath.row].type == "redeem"){
                myCell.pointLabel.text = "- \(self.pointRealmResults![indexPath.row].amount)"
            }else{
                myCell.pointLabel.text = "+ \(self.pointRealmResults![indexPath.row].amount)"
            }
            return myCell
        case 1:
            let myCell = tableView.dequeueReusableCell(withIdentifier: "ShoppingTableViewCell", for: indexPath) as! ShoppingTableViewCell
            myCell.dateLabel.text = getDate(dateString: self.shoppingRealmResults![indexPath.row].addAt!)
            myCell.mallLabel.text = String(self.shoppingRealmResults![indexPath.row].mallName!)
            myCell.shopLabel.text = String(self.shoppingRealmResults![indexPath.row].shopName!)
            myCell.pointLabel.text = "+ \(self.shoppingRealmResults![indexPath.row].point!)"
            myCell.consumLabel.text = "HKD \(self.shoppingRealmResults![indexPath.row].consumption!)"
            return myCell
        
        case 2:
            let myCell = tableView.dequeueReusableCell(withIdentifier: "ParkingTableViewCell", for: indexPath) as! ParkingTableViewCell
            myCell.dateLabel.text = getDate(dateString: self.parkingRealmResults![indexPath.row].enterAt!)
            myCell.licenseLabel.text = self.parkingRealmResults?[indexPath.row].licensePlate
            myCell.carparkLabel.text = self.parkingRealmResults?[indexPath.row].carparkName
            myCell.inLabel.text = getTime(dateString: (self.parkingRealmResults?[indexPath.row].enterAt)!)
            myCell.outLabel.text = getTime(dateString: (self.parkingRealmResults?[indexPath.row].leaveAt)!)
            return myCell
        default:
            break
            
        }
        return cell
    }
    
    private func getDate(dateString: String) -> String{
        var resArr = dateString.components(separatedBy: " ");
        if(dateString == nil || resArr.count < 3){
            return ""
        }else{
            return "\(resArr[1]) \(resArr[2]) \(resArr[3])"
        }
    }
    
    private func getTime(dateString: String) -> String{
        var resArr = dateString.components(separatedBy: " ");
        if(dateString == nil || resArr.count < 3){
            return ""
        }else{
            return "\(resArr[4])"
        }
    }
    
    @IBAction func segmentedControlActionChanged(sender: AnyObject) {
        UIView.animate(withDuration: 0.3) {
            print("self.segmentedControl.selectedSegmentIndex")
            print(self.segmentedControl.selectedSegmentIndex)
            print(self.segmentedControl.numberOfSegments)
            print(self.segmentedControl.frame.width)
            self.underlineBar.frame.origin.x = (self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex)
        }
        
//        self.tableView.reloadData();
        switch(self.segmentedControl.selectedSegmentIndex){
        case 0:
            self.getPointRecord();
            break
        case 1:
            self.getShoppingRecord();
            break
        case 2:
            self.getParkingRecord();
            break
        default:
            break
        }
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }



    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
