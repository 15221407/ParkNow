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

//var server = "http://192.168.0.106:1337/" ;

struct Malls {
    
    var mallName:String
    var mallId:String
    var district:String
    var address:String
    var contact:Int
    var poster:String
    var detials:Double
    var latitude:Double
    var longitude:Double

}

class HomeTableViewController: UITableViewController,UICollectionViewDataSource,UICollectionViewDelegate{

    var realmResults:Results<Mall>?
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showMall" {
            if let viewController = segue.destination as? MallDateilViewController {
                let cell = sender as! UICollectionViewCell
                let selectedIndex = self.collectionView!.indexPath(for: cell)
                print(selectedIndex!.row)
           
                print(realmResults![selectedIndex!.row])
                print(realmResults![(selectedIndex!.row)].district as! String)
                print(realmResults![(selectedIndex!.row)].address as! String)
//                viewController.realmResults = realmResults![selectedIndex!.row];
//                viewController.mallId =  realmResults?[selectedIndex!.row].mallId as! String
                viewController.mallName =  realmResults![selectedIndex!.row].name as! String
//                viewController.latitude =  realmResults![selectedIndex!.row].latitude as! Double
//                viewController.longitude =  realmResults![selectedIndex!.row].longitude as! Double
                viewController.address =  realmResults?[selectedIndex!.row].address as! String
//                viewController.contact =  realmResults?[selectedIndex.row].contact as! Int
        }
    }
}
    
//    @objc func collectionViewTapped(sender: AnyObject?) {
//        print("scrollViewTapped")
//        let cell = sender as! mallCollectionViewCell
//        let indexPath = self.collectionView!.indexPath(for: cell)
////        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
//        print(indexPath)
//    }
//
//
//    override func prepareForSegue(segue: UIStoryboardSegue,c
//        if segue.identifier == "showZoomController" {
//            let zoomVC = segue.destinationViewController as PhotoZoomViewController
//            let cell = sender as UICollectionViewCell
//            let indexPath = self.collectionView!.indexPathForCell(cell)
//            let userPost  = self.timeLineData.objectAtIndex(indexPath.row) as PFObject
//            zoomVC.post = userPost
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMall()
    }
    
    func getMall(){
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
//                    mall.contact = json[index]["contact"].intValue
//                    mall.parkingFee = json[index]["parkingFee"].stringValue
//                    mall.spending = json[index]["spending"].intValue
                    mall.longitude = json[index]["longitude"].doubleValue
                    mall.latitude = json[index]["latitude"].doubleValue
                    mall.poster = json[index]["poster"].stringValue
                    
                    try! realm.write {
                        realm.add(mall)
                    }
                }
                self.realmResults = realm.objects(Mall.self)
                self.collectionView.reloadData()
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

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let r = realmResults {
            return r.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mallCollectionViewCell", for: indexPath) as!  mallCollectionViewCell
        
//        if let cellImage = cell.viewWithTag(103) as?  {
        
            let url = self.realmResults?[indexPath.row].poster
            
            if let unwrappedUrl = url {
                
                Alamofire.request(unwrappedUrl).responseData {
                    response in
                    
                    if let data = response.result.value {
                        cell.collectionImageView.image = UIImage(data: data, scale:1)

                    }
                }
            }
            
//        }
        return cell
    }
    


    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if let r = realmResults {
//            return r.count
//        } else {
//            return 0
//        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mallCell", for: indexPath)
        
//        if let nameLabel = cell.viewWithTag(101) as? UILabel {
//            nameLabel.text = self.realmResults?[indexPath.row].name
//        }
//
//        if let cellImage = cell.viewWithTag(102) as? UIImageView {
//
//            let url = self.realmResults?[indexPath.row].poster
//
//            if let unwrappedUrl = url {
//
//                Alamofire.request(unwrappedUrl).responseData {
//                    response in
//
//                    if let data = response.result.value {
//                        cellImage.image = UIImage(data: data, scale:1)
//                    }
//                }
//            }
//
//        }
//
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
