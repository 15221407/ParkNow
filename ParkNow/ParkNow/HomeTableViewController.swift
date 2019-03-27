//
//  HomeTableViewController.swift
//  ParkNow
//
//  Created by christy on 17/12/2018.
//  Copyright © 2018 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift

var server = "http://192.168.0.107:1337/" ;

class HomeTableViewController: UITableViewController {
//    var json:JSON?;
    var realmResults:Results<Mall>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDatafromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    func getDatafromDB(){
        
        let realm = try! Realm()
        let url = server + "mall/json"

        Alamofire.request(url, method: .get).validate().responseJSON { response in
            print("Mall info: \(response.result.value)") // response serialization result
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
                    mall.contact = json[index]["contact"].stringValue
                    mall.parkingFee = json[index]["parkingFee"].stringValue
                    mall.spending = json[index]["spending"].intValue
                    mall.longitude = json[index]["longitude"].doubleValue
                    mall.latitude = json[index]["latitude"].doubleValue
                    mall.poster = json[index]["poster"].stringValue
                    
                    try! realm.write {
                        realm.add(mall)
                    }
                }
                self.realmResults = realm.objects(Mall.self)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "mallCell", for: indexPath)
        
        if let nameLabel = cell.viewWithTag(101) as? UILabel {
            nameLabel.text = self.realmResults?[indexPath.row].name
        }
        
        if let cellImage = cell.viewWithTag(102) as? UIImageView {
            
            let url = self.realmResults?[indexPath.row].poster
            
            if let unwrappedUrl = url {
                
                Alamofire.request(unwrappedUrl).responseData {
                    response in
                    
                    if let data = response.result.value {
                        cellImage.image = UIImage(data: data, scale:1)
                    }
                }
            }
            
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showMall" {
            
            if let viewController = segue.destination as? MallDateilViewController {
                
                var selectedIndex = tableView.indexPathForSelectedRow!
                viewController.mallId =  realmResults?[selectedIndex.row].mallId as! String
                viewController.mallName =  realmResults?[selectedIndex.row].name as! String
                viewController.latitude =  realmResults?[selectedIndex.row].latitude as! Double
                viewController.longitude =  realmResults?[selectedIndex.row].longitude as! Double
                viewController.address =  realmResults?[selectedIndex.row].address as! String
                viewController.contact =  realmResults?[selectedIndex.row].contact as! String
                 viewController.spending =  realmResults?[selectedIndex.row].spending as! Int
                
            }
        }
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
