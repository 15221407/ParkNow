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
    
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var mallLabel: UILabel!
    @IBOutlet var parkingDetailview: UIView!
    @IBOutlet var redemptionView: UIView!
    @IBOutlet var free1Btn: UIButton!
    @IBOutlet var free2Btn: UIButton!
    @IBOutlet var free3Btn: UIButton!
    
    @IBOutlet var ChargeLabel: UILabel!
    @IBOutlet var newChargeLabel: UILabel!
    
    @IBOutlet var PointLabel: UILabel!
    @IBOutlet var newPointLabel: UILabel!
    
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var cancelbtn: UIButton!
    
    var mallName:String? = nil
    var currentPoint:Int = 0
    var totalHour:Int = 0
    var hourCharge1:Int = 0
    var hourCharge2:Int = 0
    var hourCharge3:Int = 0
    var totalCharge:Int = 0
    var finalCharge:Int = 0
    var redemptionHour:Int = 0
    var redemptionPoint:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resetValue()
        let group = DispatchGroup()
        // Group our requests:
        group.enter()
        self.getPoint {
            group.leave()
        }
        group.enter()
        self.getCharge {
            group.leave()
        }
        
        group.notify(queue: .main) {
        self.setUpLabel()
        self.setUpButton()
        }
    }

    private func resetValue(){
        self.totalHour = 0
        self.totalCharge = 0
        self.finalCharge = 0
        self.redemptionHour = 0
        self.redemptionPoint = 0
        self.hourCharge1 = 0
        self.hourCharge2 = 0
        self.hourCharge3 = 0
    }
    
    private func setUpLabel(){
        self.mallLabel.text = self.mallName
        self.ChargeLabel.text = String(self.totalCharge)
        self.durationLabel.text = String(self.totalHour) + "h"
        self.PointLabel.text =  String(self.currentPoint)
        
        if( self.redemptionHour > 0 ){
            self.ChargeLabel.isHidden = false
            self.ChargeLabel.text = "Original fee:" + String(self.totalCharge)
            if(self.redemptionHour == 1 ){
                self.ChargeLabel.text = String(self.totalCharge - self.hourCharge1)
                self.PointLabel.text = String(self.currentPoint - self.hourCharge1)
            }else if (self.redemptionHour == 2 ){
                self.ChargeLabel.text = String(self.totalCharge - (self.hourCharge2))
                self.PointLabel.text = String(self.currentPoint - self.hourCharge2)
            }else if (self.redemptionHour == 3 ){
                self.ChargeLabel.text = String(self.totalCharge - (self.hourCharge3))
                self.PointLabel.text = String(self.currentPoint - self.hourCharge3)
            }
        }
 
    }
    
    private func setUpButton(){
        self.confirmBtn.isEnabled = true;
        self.cancelbtn.isEnabled = true;
        
        self.free1Btn.isEnabled = false
        self.free2Btn.isEnabled = false
        self.free3Btn.isEnabled = false
        if( self.currentPoint >= self.hourCharge3 && self.totalHour >= 3 ){
            self.free1Btn.isEnabled = true
            self.free2Btn.isEnabled = true
            self.free3Btn.isEnabled = true
        }else if( self.currentPoint >= self.hourCharge2 && self.totalHour >= 2){
            self.free1Btn.isEnabled = true
            self.free2Btn.isEnabled = true
        }else if( self.currentPoint >= self.hourCharge1 ){
            self.free1Btn.isEnabled = true
        }
    }
    
    private func getCharge(completionHandler: @escaping () -> Void) {
        Alamofire.request(server + "paymentrecord/calculate").responseString { response in
            print("Get Calculated Fee: \(response.result.value ?? "No Record")")
            let json = JSON(response.result.value)//
            var resArr = response.result.value?.components(separatedBy: ",");
            self.mallName = String(resArr?[0] ?? "")
            self.totalCharge = Int(resArr?[1] ?? "0")!
            self.totalHour =  Int(resArr?[2] ?? "0")!
            self.hourCharge1 = Int(resArr?[3] ?? "0")!
            self.hourCharge2 = Int(resArr?[4] ?? "0")!
            self.hourCharge3 = Int(resArr?[5] ?? "0")!
            completionHandler()
        }
    }
    
    
    private func getPoint(completionHandler: @escaping () -> Void) {
        
        Alamofire.request(server + "member/getPoint", method: .get).responseString { response in
            print("Get Points: \(response.result.value ?? "No data")")
            switch response.result{
            case .success(let value):
                self.currentPoint = Int(value)!
                completionHandler()
            case .failure(let error):
                self.currentPoint = 0
                completionHandler()
                break
            }
            
        }
        
    }
    
    private func updatePayment(){
        
        let parameters : Parameters = ["redemptionPoint": self.redemptionPoint , "finalCharge" : self.finalCharge]
        
        Alamofire.request(server + "paymentRecord/updateAfterPayment", method: .post, parameters: parameters).responseString { response in
            print("Update Payment: \(response.result.value ?? "No data")")
            switch response.result{
            case .success(let value):
                if(value == "Charged succefully."){
                    let alertController = UIAlertController(title: "iPark", message: value, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction)in  self.navigationController?.popToRootViewController(animated: true)}))
                    self.present(alertController, animated: true, completion: nil)
                    self.resetValue();
                }
            case .failure(let error):
                break
            }
            
        }
        
    }
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: server + "paymentRecord/prepay" )!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            self.showDropIn(clientTokenOrTokenizationKey: clientToken ?? "")
            }.resume()
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                print("Payment Result: ")
                print(result)
                print(result.paymentOptionType)
                print(result.paymentMethod!.nonce)
                print(result.paymentIcon)
                print(result.paymentDescription)
                self.postNonceToServer(paymentMethodNonce: result.paymentMethod!.nonce)
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
   
    func postNonceToServer(paymentMethodNonce: String) {
        let paymentURL = URL(string: server + "paymentRecord/calculateBeforePay")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)&redemptionHour=\(self.redemptionHour)&redemptionPoint=\(self.redemptionPoint)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            let result = String(data: data!, encoding: String.Encoding.utf8)
            print("Prepayment result: \(result ?? "No data")")
            if(result == "Charged succefully"){
//                let alertController = UIAlertController(title: "Confirm Payment", message: "You have paid $" + String(self.totalCharge), preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction)in  self.navigationController?.popToRootViewController(animated: true)}))
//                self.present(alertController, animated: true, completion: nil)
//                self.totalCharge = 0 ;
                self.updatePayment();
            }
            }.resume()
    }
    
    @IBAction func free1BtnClicked(_ sender: Any) {
        self.redemptionHour = 1
        self.redemptionPoint = hourCharge1;
        self.free1Btn.backgroundColor = UIColor(red:0.96, green:0.85, blue:0.06, alpha:1.0)
        self.free2Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.free3Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    
    @IBAction func free2BtnClicked(_ sender: Any) {
        self.redemptionHour = 2
        self.redemptionPoint = hourCharge2;
        self.free1Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.free2Btn.backgroundColor = UIColor(red:0.96, green:0.85, blue:0.06, alpha:1.0)
        self.free3Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    
    @IBAction func free3BtnClicked(_ sender: Any) {
        self.redemptionHour = 3
        self.redemptionPoint = hourCharge3;
        self.free1Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.free2Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.free3Btn.backgroundColor = UIColor(red:0.96, green:0.85, blue:0.06, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    @IBAction func clearOpiton(_ sender: Any) {
        self.redemptionHour = 0
        self.redemptionPoint = 0 ;
        self.free1Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.free2Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.free3Btn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    
    private func perpareForcharge(){
        if (finalCharge == 0){
            self.updatePayment()
        }else{
            self.fetchClientToken()
        }

    }
    
    @IBAction func confrimPayment(_ sender: Any){
        self.confirmBtn.isEnabled = false;
        self.cancelbtn.isEnabled = false;
        
        Alamofire.request(server + "paymentRecord/calculate").responseString { response in
            print("Final Check: \(response.result.value ?? "No Record")")
            switch response.result{
            case .success(let value):
                var resArr = value.components(separatedBy: ",");
                self.totalCharge = Int(resArr[1])!
                self.finalCharge = self.totalCharge - self.redemptionPoint
                let alertController = UIAlertController(title: "Confirm Payment", message: "Total Charge: $" + String(self.finalCharge), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in self.perpareForcharge() }))
                self.present(alertController, animated: true, completion: nil)
            case .failure(let error):
                break
                
            }
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
