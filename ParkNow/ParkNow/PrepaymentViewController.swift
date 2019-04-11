//
//  PrepaymentViewController.swift
//  ParkNow
//
//  Created by christy on 16/1/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree
import Alamofire
import SwiftyJSON
import Foundation

class PrepaymentViewController: UIViewController {
    @IBOutlet var totalFeeLabel: UILabel!
    @IBOutlet var parkedHourLabel: UILabel!
    @IBOutlet var feePerHourLabel: UILabel!
    @IBOutlet var mallLabel: UILabel!
    @IBOutlet var parkingDetailview: UIView!
    var feePerHour:Int = 0
    var totalFee:Int = 0
    var finalFee:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpLabel()
        self.resetValue()
        self.setUpbackground()
    }
    
    private func setUpbackground(){
//        self.parkingDetailview.backgroundImage.image = UIImage(named: "RubberMat")
    }
    private func resetValue(){
        self.feePerHour = 0
        self.totalFee = 0
        self.finalFee = 0
    }
    
    private func setUpLabel(){
        Alamofire.request(server + "parkingrecord/calculate").responseString { response in
            print("Get Calculated Fee: \(response.result.value ?? "No Record")")
            let json = JSON(response.result.value)//
            var resArr = response.result.value?.components(separatedBy: ",");
            self.totalFeeLabel.text = resArr?[0] ?? ""
            self.totalFee = Int(resArr?[0] ?? "0")!
            self.parkedHourLabel.text = String(resArr![1]) + "h"
            self.feePerHourLabel.text = "$" + String(resArr![2])
            self.feePerHour = Int(resArr?[2] ?? "0")!
            self.mallLabel.text = resArr?[3] ?? ""
        }
    }
    
    @IBAction func cancalBtnClicked(_ sender: Any) {
        if self.presentingViewController != nil {
            self.dismiss(animated: false, completion: {
                self.navigationController!.popToRootViewController(animated: true)
            })
        }
        else {
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
