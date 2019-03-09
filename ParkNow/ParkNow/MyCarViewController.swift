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
    @IBOutlet var entryDateLabel: UILabel!
    @IBOutlet var licenseLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var plateLabel: UILabel!
    @IBOutlet var parkingTimeLabel: UILabel!
    @IBOutlet var parkedTimeLabel: UILabel!
    @IBOutlet var redeemBtn: UIButton!
    //    var timer = Timer();
    var parkingTime = 0 ;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpButton()
        print("viewWillAppear")
    }
    
    func setUpButton(){
        //not allow users register their car and prepay the parking fee without login
        if(UserDefaults.standard.string(forKey: "username") != nil){
            self.registerBtn.isHidden = false;
            self.prepayBtn.isHidden = false;
            self.setUpLabel();
        }else{
            self.entryDateLabel.isHidden = true;
            self.licenseLabel.isHidden = true;
            self.registerBtn.isHidden = true;
            self.prepayBtn.isHidden = true;
            self.plateLabel.isHidden = true;
            self.dateTimeLabel.isHidden = true;
            self.parkingTimeLabel.isHidden = true;
            self.parkedTimeLabel.isHidden = true;
            self.redeemBtn.isHidden = true;
            
        }
        
    }
    
   private func setUpLabel(){
        Alamofire.request(server + "parkingrecord/getLicensePlate").responseString { response in
            print("Get LicensePlate: \(response.result.value ?? "No Record")")
            self.licenseLabel.isHidden = false;
            self.plateLabel.isHidden = false;
            self.redeemBtn.isHidden = false;
            self.plateLabel.text = response.result.value
            
            }
        Alamofire.request(server + "parkingrecord/getEnterAt").responseString { response in
            print("Get DateTime: \(response.result.value ?? "No Record")")
            self.entryDateLabel.isHidden = false;
            self.dateTimeLabel.isHidden = false;
            self.dateTimeLabel.text = response.result.value
            
        }
        
        Alamofire.request(server + "parkingrecord/getParkingTime").responseString { response in
            print("Get DateTime: \(response.result.value ?? "No Record")")
//            self.dateTimeLabel.text = response.result.value
            if( response.result.value != "No Record"){
                self.setUpTimer();
                self.parkingTime = Int(response.result.value!) ?? 0;
                self.parkingTimeLabel.isHidden = false;
                self.parkedTimeLabel.isHidden = false;
                self.parkingTimeLabel.text = "loading...";
            }else {
                self.parkingTimeLabel.isHidden = true;
                self.parkedTimeLabel.isHidden = true;
                
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
        print(parkingTimeString)
        self.parkingTimeLabel.text = parkingTimeString ;
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
            return "\(seconds) seconds"
        } else if miliseconds < 1000 * 60 * 60 {
            secondsTemp = miliseconds / 1000
            minutes = secondsTemp / 60
            seconds = (miliseconds - minutes * 60 * 1000) / 1000
            return "\(minutes) minutes \(seconds) seconds"
        } else if miliseconds < 1000 * 60 * 60 * 24 {
            minutesTemp = miliseconds / 1000 / 60
            hours = minutesTemp / 60
            minutes = (miliseconds - hours * 60 * 60 * 1000) / 1000 / 60
            seconds = (miliseconds - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(hours) hours \(minutes) minutes \(seconds) seconds"
        } else {
            hoursTemp = miliseconds / 1000 / 60 / 60
            days = hoursTemp / 24
            hours = (miliseconds - days * 24 * 60 * 60 * 1000) / 1000 / 60 / 60
            minutes = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000) / 1000 / 60
            seconds = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(days) days \(hours) hours \(minutes) minutes \(seconds) seconds"
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
