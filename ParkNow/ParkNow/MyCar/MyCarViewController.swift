//
//  MyCarViewController.swift
//  ParkNow
//
//  Created by christy on 20/1/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import Alamofire
import SwiftyJSON

class MyCarViewController: UIViewController {
    @IBOutlet var registerBtn: UIButton!
    @IBOutlet var prepayBtn: UIButton!
    @IBOutlet var plateLabel: UILabel!
    @IBOutlet var entryDateLabel: UILabel!
    @IBOutlet var entryDateLabel2: UILabel!
    @IBOutlet var enterAtLabel: UILabel!
    @IBOutlet var enterAtLabel2: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var durationLabel2: UILabel!
    @IBOutlet var whereBtn: UIButton!
    var parkingTime = 0 ;
    var licensePlate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpButton()
        self.setUpLabel()
    }
    
    @IBAction func whereBtnClicked(_ sender: Any) {
            let parameters : Parameters = ["licensePlate": self.licensePlate]
         Alamofire.request(server + "RFIDTag/getLocation", method: .post, parameters: parameters).responseString { response in
            print("Get Location: \(response.result.value ?? "No Record")")
            switch response.result{
            case .success(let value):
                
                if (value == "Please register a tag first."){
                     let alertController = UIAlertController(title: "Where's My Car", message: value, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    //set imageView for map
                    let imageView = UIImageView(frame: CGRect(x: 20, y: 90, width: 220, height: 220))
                    let alertController = UIAlertController(title: "Where's My Car", message: "My car is at " + value, preferredStyle: .alert)
                    if( value == "entrance"){
                        imageView.image = UIImage(named: "none")
                    }else if (value == "zoneA"){
                        imageView.image = UIImage(named: "zoneA")
                    }
                     alertController.view.addSubview(imageView)
                    
                    //add height
                    var height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.58)
                    alertController.view.addConstraint(height);
                    
                    //cancel button
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .failure(let error):
                break
            }
        }
    }
    
    
    private func setUpButton(){
        //not allow users register their car and prepay the parking fee without login
        if(UserDefaults.standard.string(forKey: "username") != nil){
            self.registerBtn.isHidden = false;
            self.prepayBtn.isHidden = true;
            self.whereBtn.isHidden = true;
            Alamofire.request(server + "parkingrecord/getParkingState").responseString { response in
                print("Get Parking State: \(response.result.value ?? "No Record")")
                switch response.result{
                case .success(let value):
//                    let json:JSON = JSON(value);
                    var resArr = value.components(separatedBy: ",");
                    if(resArr[0] == "enter" && resArr[1] == "N" ){
                        self.prepayBtn.isHidden = false;
                        self.whereBtn.isHidden = false;
                    }else if (resArr[0] == "enter" && resArr[1] == "Y" ){
                        self.prepayBtn.isHidden = false;
                        self.prepayBtn.isEnabled = false;
                        self.whereBtn.isHidden = false;
                    }
                case .failure(let error):
                    break
                }
            }
            
        }else{
            self.registerBtn.isHidden = true;
            self.prepayBtn.isHidden = true;
            self.whereBtn.isHidden = true;
        }
    }
    
   private func setUpLabel(){
        self.licensePlate = "";
        self.plateLabel.text = "--";
        self.entryDateLabel2.text = "--";
        self.enterAtLabel2.text = "--";
        self.durationLabel2.text = "--";
    
        if(UserDefaults.standard.string(forKey: "username") != nil){
            Alamofire.request(server + "parkingrecord/getLicensePlate").responseString { response in
                print("Get LicensePlate: \(response.result.value ?? "No Record")")
                switch response.result{
                case .success(let value):
                    let json:JSON = JSON(value);
                    if(json != "No Record"){
                        self.plateLabel.text = value ;
                        self.licensePlate = value;
                    }
                case .failure(let error):
                    break
                }
        }
        
            Alamofire.request(server + "parkingrecord/getEnterAt").responseString { response in
                print("Get DateTime: \(response.result.value ?? "No Record")")
                switch response.result{
                case .success(let value):
                    let json:JSON = JSON(value);
                    if(json != "No Record"){
                        var resArr = response.result.value?.components(separatedBy: ",");
                        self.entryDateLabel2.text = resArr![0]
                        self.enterAtLabel2.text = resArr![1]
                    }
                case .failure(let error):
                    break
                }
        }
            Alamofire.request(server + "parkingrecord/getParkingTime").responseString { response in
                print("Get DateTime: \(response.result.value ?? "No Record")")
                switch response.result{
                case .success(let value):
                    let json:JSON = JSON(value);
                    if(json != "No Record"){
    //                    self.setUpTimer();
                        self.parkingTime = Int(response.result.value!) ?? 0;
                        self.durationLabel2.isHidden = false;
                        self.durationLabel2.text = self.convertTime(miliseconds: self.parkingTime);
                    }
                case .failure(let error):
                    break
                }
            }
        }
    }
    
    private func setUpTimer(){
        //set up a timer
        var timer : Timer? = nil;
        timer?.invalidate();
        timer = nil;
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.onTimerFires), userInfo: nil, repeats: true)
    }
    
    @objc func onTimerFires()
    {
        var parkingTimeString = "" ;
        self.parkingTime += 1000 ;
        parkingTimeString = self.convertTime(miliseconds: self.parkingTime) ;
//        print(parkingTimeString)
        self.durationLabel2.text = parkingTimeString ;
    }
    
    func convertTime(miliseconds: Int) -> String {
        
        var seconds: Int = 0
        var minutes: Int = 0
        var hours: Int = 0
        var days: Int = 0
        var secondsTemp: Int = 0
        var minutesTemp: Int = 0
        var hoursTemp: Int = 0
        
        if miliseconds < 1000 {
            return ""
        } else if miliseconds < 1000 * 60 {
            seconds = miliseconds / 1000
            return "0h 0m \(seconds)s"
        } else if miliseconds < 1000 * 60 * 60 {
            secondsTemp = miliseconds / 1000
            minutes = secondsTemp / 60
            seconds = (miliseconds - minutes * 60 * 1000) / 1000
            return "0h \(minutes)m \(seconds)s"
        } else if miliseconds < 1000 * 60 * 60 * 24 {
            minutesTemp = miliseconds / 1000 / 60
            hours = minutesTemp / 60
            minutes = (miliseconds - hours * 60 * 60 * 1000) / 1000 / 60
            seconds = (miliseconds - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(hours)h \(minutes)m \(seconds)s"
        } else {
            hoursTemp = miliseconds / 1000 / 60 / 60
            days = hoursTemp / 24
            hours = (miliseconds - days * 24 * 60 * 60 * 1000) / 1000 / 60 / 60
            minutes = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000) / 1000 / 60
            seconds = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(days)d \(hours)h \(minutes)m \(seconds)s"
        }
    }


    /*    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
