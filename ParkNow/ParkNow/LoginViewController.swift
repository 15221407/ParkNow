//
//  LoginViewController.swift
//  ParkNow
//
//  Created by christy on 17/12/2018.
//  Copyright © 2018 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

import Foundation
import RealmSwift

class LoginViewController: UIViewController {
    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signinBtnClicked(_ sender: Any) {
        
        let parameters : Parameters = ["username": usernameTF.text!, "password": passwordTF.text!]
        
        Alamofire.request("http://192.168.0.183:1337/user/login", method: .post, parameters: parameters)
            .responseString { response in
                print("Response String: \(response.result.value ?? "No data")")
                switch response.result{
                    
                case .success(let value):
                    var json:JSON = JSON(value);
                    
                    if(json == "Sign In Sccessfully" ){
                        UserDefaults.standard.set(self.usernameTF.text!, forKey: "username")
    
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

    }}
