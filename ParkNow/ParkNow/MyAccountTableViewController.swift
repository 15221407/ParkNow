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
import CoreImage

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
        self.setUpButton()

        tableView.reloadData()
    }
    
    func setUpButton(){
        let Loginbutton = view.viewWithTag(101) as? UIButton
        let Logoutbutton = view.viewWithTag(102) as? UIButton
        if(UserDefaults.standard.string(forKey: "username") != nil){
            Logoutbutton!.setTitle("Sign out", for: .normal)
            Logoutbutton?.isHidden = false
            Loginbutton?.isHidden = true
        }else if(UserDefaults.standard.string(forKey: "username") == nil){
            Loginbutton!.setTitle("Please sign in first.", for: .normal)
            Loginbutton?.isHidden = false
            Logoutbutton?.isHidden = true
        }
    }
    
    // MARK: - Table view data source
    
    
    
    @IBAction func accountLogout(_ sender: Any) {
//        let username = UserDefaults.standard.string(forKey: "userid")
//        let password = UserDefaults.standard.string(forKey: "userpw")
        
//        let parameters : Parameters = ["username": username , "password": password]
        
        Alamofire.request("http://192.168.0.183:1337/user/logout", method: .get).responseString { response in
                print("Response String: \(response.result.value ?? "No data")")
                switch response.result{
                case .success(let value):
                    var json:JSON = JSON(value);
                    
                    let alertController = UIAlertController(title: "Message", message: "Logout successfully.", preferredStyle: .alert)
                
                    
                    
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    UserDefaults.standard.set(nil, forKey: "username")
                    self.setUpButton()
                    
                case .failure(let error):
                    break
                    
                }
        }
    }

    @IBAction func qrCodeClicked(_ sender: Any) {
        if(UserDefaults.standard.string(forKey: "username") != nil){
            self.getQRCode()
        }else{
            let alertController = UIAlertController(title: "Message", message: "Please login first.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func getQRCode(){
        let username = UserDefaults.standard.string(forKey: "username")
        let parameters : Parameters = ["username":username!]
        
        Alamofire.request("http://192.168.0.183:1337/user/qrCode", method: .post, parameters: parameters).responseString { response in
                print("QR Code: \(response.result.value ?? "No data")")
                switch response.result{
    
                case .success(let value):
//                    var json:JSON = JSON(value);
                    let currentDateTime = Date()
    
                    // initialize the date formatter and set the style
                    let formatter = DateFormatter()
                    formatter.timeStyle = .medium
                    formatter.dateStyle = .medium
                    // get the date time String from the date object
                    let timeString = "Updated at " + formatter.string(from: currentDateTime)

                    
                    let alertController = UIAlertController(title: "QR Code", message: timeString, preferredStyle: .alert)
                    
                    //set imageView for QR Code
                    let imageView = UIImageView(frame: CGRect(x: 10, y: 90, width: 250, height: 250))
                    let imageUrl = URL(string:response.result.value! )!
                    let imageData = try! Data(contentsOf: imageUrl)
                    imageView.image = UIImage(data: imageData, scale:1)
                    alertController.view.addSubview(imageView)
                    
                    //add height
                    var height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.58)
                    alertController.view.addConstraint(height);
                    UIScreen.main.brightness = CGFloat(0.6)
                    
                    //refresh button
                    let refreshAction = UIAlertAction(title: "Refresh", style: .default, handler: {( alertController: UIAlertAction?) in self.getQRCode()})
                    alertController.addAction(refreshAction)
                
                    //cancel button
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                   alertController.addAction(cancelAction)
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


