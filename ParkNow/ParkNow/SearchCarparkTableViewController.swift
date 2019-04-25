//
//  CarparkTableViewController.swift
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

struct Offer{
    
}

class SearchCarparkTableViewController: UITableViewController , UISearchBarDelegate{
    
    var parkArr = [Carparks]()
    var initParkArr = [Carparks]()
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSearchBar()
        self.hideKeyboardWhenTappedAround()
        tableView.register(UINib(nibName: "CarparkTableViewCell", bundle: nil), forCellReuseIdentifier: "CarparkTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.parkArr.removeAll()
        self.getCarpark()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOffer(carparkId:String){
        let parameters : Parameters = ["carparkId": carparkId ]
        Alamofire.request(server + "offer/json", method: .get).validate().responseJSON { response in
            print("Car Offer: \(response.result.value)") // response serialization result
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                for index in 0..<json.count {
                    self.parkArr.append(
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
                    self.tableView.reloadData()
                    self.saveParkArr()
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    //Search bar
    private func setUpSearchBar(){
        let searchBar = UISearchBar(frame: CGRect(x:0,y:0,width:(UIScreen.main.bounds.width),height:70))
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if searchText.isEmpty {
            parkArr = initParkArr
            self.tableView.reloadData()
            print("parkArr = initParkArr")
        }else {
            print("filterTableView(text:searchText)")
            filterTableView(text:searchText)
            self.tableView.reloadData()
        }
    }
    
    func filterTableView(text:String) {
        //fix of not searching when backspacing
        parkArr = parkArr.filter({ (model) -> Bool in
            return model.carparkName.lowercased().contains(text.lowercased())
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.parkArr.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarparkTableViewCell", for: indexPath) as! CarparkTableViewCell
        cell.carparkLabel.text = self.parkArr[indexPath.row].carparkName
        cell.mallLabel.text = self.parkArr[indexPath.row].mallName
        cell.lotsLabel.text = "\(String(self.parkArr[indexPath.row].lots))"
        cell.navBtn.tag = indexPath.row
        cell.navBtn.addTarget(self, action: #selector(self.navBtnClicked(_:)), for: .touchUpInside);
        return cell
    }
    
    @IBAction func navBtnClicked(_ sender: Any) {
        let index = (sender as AnyObject).tag
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlStr = "comgooglemaps://?q=\(self.parkArr[index!].carparkName)&center=\(self.parkArr[index!].latitude),\(self.parkArr[index!].longitude)&zoom=14&views=traffic"
            if let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            print("Can't use comgooglemaps://");
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(indexPath.row)
        self.getOffer(carparkId: String(self.parkArr[indexPath.row].carparkId))
        var msg = "Mon - Fri: $" + String(parkArr[indexPath.row].chargeOnWeekday) +
            " \nSat & Sun: $" + String(parkArr[indexPath.row].chargeOnWeekends)
        let alertController = UIAlertController(title: "Charge", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func getCarpark(){
        Alamofire.request(server + "carpark/json", method: .get).validate().responseJSON { response in
            print("Car Park info: \(response.result.value)") // response serialization result
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                for index in 0..<json.count {
                    self.parkArr.append(
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
                    self.tableView.reloadData()
                    self.saveParkArr()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    

    func saveParkArr(){
        self.initParkArr = self.parkArr
    }
    /*
     
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
