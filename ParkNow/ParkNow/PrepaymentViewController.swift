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

class PrepaymentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchClientToken()
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
        let clientTokenURL = NSURL(string: "http://192.168.0.183:1337/parkingRecord/prepay")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            self.showDropIn(clientTokenOrTokenizationKey: clientToken ?? "");
            }.resume()
    
    }
    

    
    func postNonceToServer(paymentMethodNonce: String) {
        // Update URL with your server
        let paymentURL = URL(string: "http://192.168.0.183:1337/parkingRecord/paymentMethod")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            }.resume()
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
