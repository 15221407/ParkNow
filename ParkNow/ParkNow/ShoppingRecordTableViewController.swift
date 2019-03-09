//
//  ShoppingRecordTableViewController.swift
//  ParkNow
//
//  Created by christy on 5/1/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import UIKit
import Alamofire
import SwiftyJSON

import Foundation
import RealmSwift
import CoreImage

class ShoppingRecordTableViewController: UITableViewController {
    var realmResults:Results<ShoppingRecord>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDatafromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData();
    }


    
    func getDatafromDB(){
        
        let realm = try! Realm()
        let url = server + "member/showShoppingRecord"
        
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            
            print("Record: \(response.result.value)") // response serialization result
            
            switch response.result {
                
            case .success(let value):
                
                //self.json = JSON(value)
                let json:JSON = JSON(value);
                
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                
                for index in 0..<json.count {
                    let shoppingRecord = ShoppingRecord()
                    shoppingRecord.mallName = json[index]["mallName"].stringValue
                    shoppingRecord.shopName = json[index]["shopName"].stringValue
                    shoppingRecord.consumption = json[index]["consumption"].stringValue
                    shoppingRecord.point = json[index]["point"].stringValue
                    
                    try! realm.write {
                        realm.add(shoppingRecord)
                    }
                }
                self.realmResults = realm.objects(ShoppingRecord.self)
                
                self.tableView.reloadData()
                
                
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let r = realmResults {
            return r.count
        } else {
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingRecordCell", for: indexPath)

        if let shopLabel = cell.viewWithTag(101) as? UILabel {
            var mallName = self.realmResults?[indexPath.row].mallName as! String
            var shopName = self.realmResults?[indexPath.row].shopName as! String
            shopLabel.text = mallName + " - " + shopName
        }
        
        if let pointLabel = cell.viewWithTag(102) as? UILabel {
            var point = self.realmResults?[indexPath.row].point as! String
            var consumption = self.realmResults?[indexPath.row].consumption as! String
            pointLabel.text = "Spending: $" + consumption + ". Earned point: " + point
        }
        
        return cell
    }
 

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
