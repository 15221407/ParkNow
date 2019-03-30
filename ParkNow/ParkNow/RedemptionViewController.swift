//
//  RedemptionViewController.swift
//  ParkNow
//
//  Created by christy on 7/3/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree
import Alamofire
import SwiftyJSON
import Foundation


class RedemptionViewController: UIViewController {

    @IBOutlet var oneHourBtn: UIButton!
    @IBOutlet var twoHourBtn: UIButton!
    @IBOutlet var threeHourBtn: UIButton!
    @IBOutlet var finalFeeLabel: UILabel!
    @IBOutlet var myPointLabel: UILabel!
    @IBOutlet var oriFeeLabel: UILabel!
    @IBOutlet var oriPointLabel: UILabel!
    
    var pointPerHour:Int = 0
    var totalFee:Int = 0
    var finalFee:Int = 0
    var redemptionHour:Int = 0
    var currentPoint:Int = 0
    var parkingHour:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        self.getParkingFee {
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.setUpLabel()
            self.setUpButton()
        }
    }

    
    private func resetValue(){
        self.pointPerHour = 0
        self.totalFee = 0
        self.finalFee = 0
        self.redemptionHour = 0
    }
    
    private func setUpButton(){
        self.oneHourBtn.setTitle( "One Hour Free Parking ( " + String( 1 * pointPerHour) + "points )", for: .normal)
        self.twoHourBtn.setTitle( "Two Hour Free Parking (" + String( 2 * pointPerHour) + "points )", for: .normal)
        self.threeHourBtn.setTitle( "Three Hour Free Parking (" + String( 3 * pointPerHour) + "points )", for: .normal)
        
        self.oneHourBtn.isEnabled = false
        self.twoHourBtn.isEnabled = false
        self.threeHourBtn.isEnabled = false
        if( currentPoint >= (3 * pointPerHour) && self.parkingHour >= 3 ){
            self.oneHourBtn.isEnabled = true
            self.twoHourBtn.isEnabled = true
            self.threeHourBtn.isEnabled = true
        }else if( currentPoint >= (2 * pointPerHour) && self.parkingHour >= 2){
            self.oneHourBtn.isEnabled = true
            self.twoHourBtn.isEnabled = true
        }else if( currentPoint >= pointPerHour ){
            self.oneHourBtn.isEnabled = true
        }
    }
        
    private func setUpLabel(){
        if(self.redemptionHour > 0 ){
            self.oriFeeLabel.isHidden = false
            self.oriFeeLabel.text = "Original fee:" + String(self.totalFee)
            self.finalFee = self.totalFee - (self.redemptionHour * self.pointPerHour)
            self.finalFeeLabel.text =  "$" + String(self.finalFee)
            self.oriPointLabel.isHidden = false
            self.oriPointLabel.text = "Original point:" + String(self.currentPoint)
            self.myPointLabel.text = String(self.currentPoint - (self.redemptionHour * self.pointPerHour) )
        }else{
            self.oriPointLabel.isHidden = true
            self.myPointLabel.text = String(self.currentPoint)
            self.oriFeeLabel.isHidden = true
            self.finalFeeLabel.text =  "$" + String(self.totalFee)
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
    
    private func getParkingFee(completionHandler: @escaping () -> Void) {
        Alamofire.request(server + "parkingrecord/calculate").responseString { response in
            print("Get Calculated Fee: \(response.result.value ?? "No Record")")
            let json = JSON(response.result.value)//
            var resArr = response.result.value?.components(separatedBy: ",");
            self.totalFee = Int(resArr?[0] ?? "0")!
            self.parkingHour = Int(resArr?[1] ?? "0")!
            self.pointPerHour = Int(resArr?[2] ?? "0")!
            self.finalFee = self.totalFee - (self.redemptionHour * self.pointPerHour)
            completionHandler()
        }

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
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: server + "parkingRecord/prepay" )!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            self.showDropIn(clientTokenOrTokenizationKey: clientToken ?? "");
            }.resume()
        
    }
    
    
    
    func postNonceToServer(paymentMethodNonce: String) {
        let paymentURL = URL(string: server + "parkingRecord/calculateBeforePay")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)&redemptionHour=\(self.redemptionHour)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            if(response != nil){
                print(response)
            }
            }.resume()
    }

    
    @IBAction func oneHourFeeParking(_ sender: Any) {
        self.redemptionHour = 1
        self.oneHourBtn.backgroundColor = UIColor(red:0.96, green:0.85, blue:0.06, alpha:1.0)
        self.twoHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.threeHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    
    @IBAction func twoHourFeeParking(_ sender: Any) {
        self.redemptionHour = 2
        self.oneHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.twoHourBtn.backgroundColor = UIColor(red:0.96, green:0.85, blue:0.06, alpha:1.0)
        self.threeHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    
    @IBAction func threeHourFeeParking(_ sender: Any) {
        self.redemptionHour = 3
        self.oneHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.twoHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.threeHourBtn.backgroundColor = UIColor(red:0.96, green:0.85, blue:0.06, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    @IBAction func clearOpiton(_ sender: Any) {
        self.redemptionHour = 0
        self.oneHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.twoHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.threeHourBtn.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        self.setUpLabel()
        self.setUpButton()
    }
    
 
    
    @IBAction func confrimPayment(_ sender: Any){
        Alamofire.request(server + "parkingrecord/calculate").responseString { response in
            print("Final Check: \(response.result.value ?? "No Record")")
            switch response.result{
            case .success(let value):
                var resArr = value.components(separatedBy: ",");
                self.totalFee = Int(resArr[0] )!
                self.pointPerHour = Int(resArr[2] )!
                self.finalFee = self.totalFee - (self.redemptionHour * self.pointPerHour)
                let alertController = UIAlertController(title: "Confirm Payment", message: "Total parking Fee: $" + String(self.finalFee), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in self.fetchClientToken() }))
                self.present(alertController, animated: true, completion: nil)
            case .failure(let error):
                break
                
            }
        }
        
    }
    
    static func makeSlashText(_ text:String) -> NSAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        return attributeString
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

