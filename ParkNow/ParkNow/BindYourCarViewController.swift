//
//  BindYourCarViewController.swift
//  ParkNow
//
//  Created by christy on 6/1/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

import Foundation
import RealmSwift

class BindYourCarViewController: UIViewController {
    
    @IBOutlet var licensePlateTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    


    
    func bindYourCar() {
        let parameters : Parameters = ["licensePlate": licensePlateTF.text!]
        
        Alamofire.request("http://192.168.0.183:1337/car/bindYourCar", method: .post, parameters: parameters)
            .responseString { response in
                print("Bind your car: \(response.result.value ?? "No data")")
                switch response.result{
                    
                case .success(let value):
                    var json:JSON = JSON(value);
                    
                    if(json == "Successfully Created!" ){
                        
                        let alertController = UIAlertController(title: "Message", message: response.result.value, preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction)in  self.navigationController?.popToRootViewController(animated: true)}))
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }else{
                        let alertController = UIAlertController(title: "Message", message: response.result.value, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                case .failure(let error):
                    break
                    
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
}
