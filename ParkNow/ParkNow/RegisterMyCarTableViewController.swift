//
//  RegisterMyCarTableViewController.swift
//  ParkNow
//
//  Created by christy on 30/3/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift

class tableViewCell:UITableViewCell{
    @IBOutlet var myCarLabel: UILabel!
    @IBOutlet var removeBtn: UIButton!
    
}

class RegisterMyCarTableViewController: UITableViewController {
    @IBOutlet var licenseTF: UITextField!
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var registerBtn: UIButton!
    
    
    var realmResults:Results<Car>?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCar()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.warningLabel.isHidden = true
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
         self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getCar(){
        
        let realm = try! Realm()

        Alamofire.request(server + "car/json", method: .get).validate().responseJSON { response in
            print("Car info: \(response.result.value)") // response serialization result
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                for index in 0..<json.count {
                    let car = Car()
                    car.uid = json[index]["uid"].stringValue
                    car.licensePlate = json[index]["licensePlate"].stringValue
                    try! realm.write {
                        realm.add(car)
                    }
                }
                self.realmResults = realm.objects(Car.self)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    

    @IBAction func registerBtnClicked(_ sender: Any) {
        self.registerBtn.isEnabled = false
        self.warningLabel.isHidden = true
        
        if(UserDefaults.standard.string(forKey: "username") != nil){
            if self.licenseTF.text != ""{
                self.registerMyCar();
            }else{
                self.warningLabel.isHidden = false
                self.warningLabel.text = "Please fill in."
                self.registerBtn.isEnabled = true
            }
        }else{
            let alertController = UIAlertController(title: "ParkNow", message: "Please login first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.registerBtn.isEnabled = true
        }
    }
    
    func registerMyCar() {
        let parameters : Parameters = ["licensePlate": licenseTF.text!]
        Alamofire.request(server + "car/registerYourCar", method: .post, parameters: parameters)
            .responseString { response in
                print("Register your car: \(response.result.value ?? "No data")")
                switch response.result{
                case .success(let value):
                    var json:JSON = JSON(value);
                    if(json == "Successfully registerd!" ){
                        let alertController = UIAlertController(title: "ParkNow", message: response.result.value, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }else{
                        let alertController = UIAlertController(title: "ParkNow", message: response.result.value, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    self.registerBtn.isEnabled = true
                case .failure(let error):
                    break
                }
                self.tableView.reloadData()
        }
    }
    
    
    private func removeCar(licensePlate:String){
        let parameters : Parameters = ["licensePlate": licensePlate]
        Alamofire.request(server + "car/removeCar", method: .post, parameters: parameters)
            .responseString { response in
                print("Remove car: \(response.result.value ?? "No data")")
                switch response.result{
                case .success(let value):
                    self.tableView.reloadData()
                case .failure(let error):
                    break
                }
        }
    }
    
    @IBAction func removeBtnClicked(_ sender: UIButton) {
        let row = sender.tag
        let alertController = UIAlertController(title: "ParkNow", message: "Confirm remove?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in self.removeCar(licensePlate: (self.realmResults?[row].licensePlate)!) }))
         self.present(alertController, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let r = realmResults {
            return r.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath) as! tableViewCell
        print(self.realmResults?[indexPath.row].licensePlate! ?? "")
        cell.myCarLabel.text  = self.realmResults?[indexPath.row].licensePlate
        cell.removeBtn.tag = indexPath.row;
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
