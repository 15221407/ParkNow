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

struct Parking{
    var mallName:String
    var carparkName: String
    var enterAt:String
    var leaveAt: String
    var licensePlate: String
}

struct Point{
    var mallName:String
    var recordType: String
    var amount:String
    var actionAt: String

}

struct Shopping{
    var mallName:String
    var shopName: String
    var consumption:String
    var point: String
    var addAt: String
}


class MyRecordTableViewController: UITableViewController {

      var parkingArr = [Parking]()
    var shoppingArr = [Shopping]()
    var pointArr = [Point]()
    
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
            self.getPointRecord();
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
        

    }

    private func registerNib(){
            tableView.register(UINib(nibName: "PointTableViewCell", bundle: nil), forCellReuseIdentifier: "PointTableViewCell")
            tableView.register(UINib(nibName: "ShoppingTableViewCell", bundle: nil), forCellReuseIdentifier: "ShoppingTableViewCell")
            tableView.register(UINib(nibName: "ParkingTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingTableViewCell")
    }
    
    private func getShoppingRecord(){

        Alamofire.request(server + "shoppingRecord/json", method: .get).validate().responseJSON { response in
            print("Shopping Record: \(response.result.value)") // response serialization resul
            switch response.result {
                
            case .success(let value):
                let json:JSON = JSON(value);
                self.shoppingArr.removeAll()
                for index in 0..<json.count {
                    self.shoppingArr.append(
                        Shopping(
                            mallName: "\(json[index]["mallName"].stringValue)",
                            shopName : "\(json[index]["shopName"].stringValue)",
                            consumption : "\(json[index]["consumption"].stringValue)",
                            point: "\(json[index]["gainedPoint"].stringValue)",
                            addAt :"\(json[index]["addAt"].stringValue)"
                        )
                    )
                }
                self.shoppingArr = self.shoppingArr.reversed()
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getPointRecord(){


        Alamofire.request(server + "pointRecord/json", method: .get).validate().responseJSON { response in
            print("Point Record: \(response.result.value)") // response serialization resul
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                self.pointArr.removeAll()
                for index in 0..<json.count {
                    self.pointArr.append(
                        Point(
                            mallName: "\(json[index]["mallName"].stringValue)",
                            recordType : "\(json[index]["type"].stringValue)",
                            amount : "\(json[index]["amount"].stringValue)",
                            actionAt : "\(json[index]["actionAt"].stringValue)"
                        )
                    )

                }
                self.pointArr = self.pointArr.reversed()

                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getParkingRecord(){

        Alamofire.request(server + "parkingRecord/json", method: .get).validate().responseJSON { response in
            print("Parking Record: \(response.result.value)") // response serialization resul
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                self.parkingArr.removeAll()
                for index in 0..<json.count {
                    self.parkingArr.append(
                        Parking(
                            mallName: "\(json[index]["mallName"].stringValue)",
                            carparkName : "\(json[index]["carparkName"].stringValue)",
                            enterAt : "\(json[index]["enterAt"].stringValue)",
                            leaveAt : "\(json[index]["leaveAt"].stringValue)",
                            licensePlate : "\(json[index]["licensePlate"].stringValue)"
                        )
                    )
                }

                self.parkingArr = self.parkingArr.reversed()
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
                    return pointArr.count
            case 1:
                    return shoppingArr.count
            case 2:
                    return parkingArr.count
   
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
            myCell.dateLabel.text = getDate(dateString:self.pointArr[indexPath.row].actionAt)
            myCell.mallLabel.text = self.pointArr[indexPath.row].mallName
            if(self.pointArr[indexPath.row].recordType == "redeem"){
                myCell.pointLabel.text = "- \(self.pointArr[indexPath.row].amount) points"
                myCell.typeImage.image = UIImage(named: "out")
                
            }else{
                myCell.pointLabel.text = "+ \(self.pointArr[indexPath.row].amount) points"
                myCell.typeImage.image = UIImage(named: "in")
            }

            return myCell
        case 1:
            let myCell = tableView.dequeueReusableCell(withIdentifier: "ShoppingTableViewCell", for: indexPath) as! ShoppingTableViewCell
            myCell.dateLabel.text = getDate(dateString: self.shoppingArr[indexPath.row].addAt)
            myCell.mallLabel.text = String(self.shoppingArr[indexPath.row].mallName)
            myCell.shopLabel.text = String(self.shoppingArr[indexPath.row].shopName)
            myCell.pointLabel.text = "+ \(self.shoppingArr[indexPath.row].point) points"
            myCell.consumLabel.text = "HKD \(self.shoppingArr[indexPath.row].consumption)"
            return myCell
        
        case 2:
            let myCell = tableView.dequeueReusableCell(withIdentifier: "ParkingTableViewCell", for: indexPath) as! ParkingTableViewCell
            myCell.dateLabel.text = getDate(dateString: self.parkingArr[indexPath.row].enterAt)
            myCell.licenseLabel.text = self.parkingArr[indexPath.row].licensePlate
            myCell.carparkLabel.text = self.parkingArr[indexPath.row].carparkName
            myCell.inLabel.text = getTime(dateString: (self.parkingArr[indexPath.row].enterAt))
            myCell.outLabel.text = getTime(dateString: (self.parkingArr[indexPath.row].leaveAt))
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
