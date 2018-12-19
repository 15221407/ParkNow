//
//  MyAccountTableViewController.swift
//  ParkNow
//
//  Created by christy on 19/12/2018.
//  Copyright © 2018 christy. All rights reserved.
//

import UIKit
import UIKit
import Alamofire
import SwiftyJSON

import Foundation
import RealmSwift

class MyAccountTableViewController: UITableViewController {
var userLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let Loginbutton = view.viewWithTag(101) as? UIButton
        let Logoutbutton = view.viewWithTag(102) as? UIButton
            if(UserDefaults.standard.string(forKey: "userid") != nil){
                Logoutbutton!.setTitle("Sign out", for: .normal)
                Logoutbutton?.isHidden = false
                Loginbutton?.isHidden = true
            }else if(UserDefaults.standard.string(forKey: "userid") == nil){
                Loginbutton!.setTitle("Please sign in first.", for: .normal)
                Loginbutton?.isHidden = false
                Logoutbutton?.isHidden = true
            }
    
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    
    
    @IBAction func accountLogout(_ sender: Any) {
        Alamofire.request("https://192.168.0.183:1337/user/logout", method: .post)
            .responseString { response in
                print("Response String: \(response.result.value ?? "No data")")
                switch response.result{
                case .success(let value):
                    var json:JSON = JSON(value);
                    
                    let alertController = UIAlertController(title: "Message", message: "Logout successfully.", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    UserDefaults.standard.set(nil, forKey: "userid")
                    
                    self.userLogin = false
                    
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    break
                    
                }
        }
    }

    @IBAction func qrCodeClicked(_ sender: Any) {
        if(UserDefaults.standard.string(forKey: "userid") != nil){
            self.getQRCode()
        }else{
            let alertController = UIAlertController(title: "Message", message: "Please login first.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func getQRCode(){
        Alamofire.request("https://192.168.0.183:1337/user/qrCode", method: .post)
            .responseString { response in
                print("QR Code: \(response.result.value ?? "No data")")
                switch response.result{
    
                case .success(let value):
                    var json:JSON = JSON(value);
                    
                    let alertController = UIAlertController(title: "QR Code", message: response.result.value, preferredStyle: .alert)
                
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                case .failure(let error):
                    break
                }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)

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
