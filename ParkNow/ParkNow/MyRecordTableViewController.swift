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
    var pointRealmResults:Results<ShoppingRecord>?
    var parkingRealmResults:Results<ShoppingRecord>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(UserDefaults.standard.string(forKey: "username") != nil){
            self.getShoppingRecord();
            self.setSegmentControl();
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setSegmentControl(){
        
        // First segment is selected by default
        self.segmentedControl.selectedSegmentIndex = 0
        // This needs to be false since we are using auto layout constraints
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        // Constrain the segmented control to the top of the container view
        self.segmentedControl.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        // Constrain the segmented control width to be equal to the container view width
        self.segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        // Constraining the height of the segmented control to an arbitrarily chosen value
        self.segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        // Add lines below the segmented control's tintColor
        self.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        self.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.orange
            ], for: .selected)
    }
    
    private func getShoppingRecord(){
        
        let realm = try! Realm()
        let url = server + "member/showShoppingRecord"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            print("Shopping Record: \(response.result.value)") // response serialization resul
            switch response.result {
                
            case .success(let value):

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
                self.shoppingRealmResults = realm.objects(ShoppingRecord.self)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        
        switch(self.segmentedControl.selectedSegmentIndex)
        {
        case 0:
            if let r = self.shoppingRealmResults {
                return r.count
            } else {
                return 0
            }
            break
        case 1:
            if let r = self.shoppingRealmResults {
                return r.count
            } else {
                return 0
            }
            break
            
        case 2:
            if let r = self.shoppingRealmResults {
                return r.count
            } else {
                return 0
            }
            break
            
        default:
            break
            
        }
        
        return returnValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        print(self.segmentedControl.selectedSegmentIndex)
        switch(self.segmentedControl.selectedSegmentIndex)
        {
        case 0:
            myCell.textLabel!.text = self.shoppingRealmResults?[indexPath.row].mallName as! String
            break
        case 1:
            myCell.textLabel!.text = self.shoppingRealmResults?[indexPath.row].mallName as! String
            break
            
        case 2:
            myCell.textLabel!.text = self.shoppingRealmResults?[indexPath.row].mallName as! String
            break
            
        default:
            break
            
        }
        return myCell
    }
    
    //    @IBAction func refreshButtonTapped(sender: AnyObject) {
    //        self.tableView.reloadData()
    //    }
    
    @IBAction func segmentedControlActionChanged(sender: AnyObject) {
        self.tableView.reloadData()
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
