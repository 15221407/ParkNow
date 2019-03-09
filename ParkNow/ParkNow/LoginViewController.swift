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
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signinBtnClicked(_ sender: Any) {
        
        let parameters : Parameters = ["username": usernameTF.text!, "password": passwordTF.text!]

        Alamofire.request(server + "user/login", method: .post, parameters: parameters)
            .responseString { response in
                print("Response String: \(response.result.value ?? "No data")")
                switch response.result{
                    
                case .success(let value):
                    var json:JSON = JSON(value);
                    if(json == "Sign In Sccessfully" ){
                        self.getUserId()
                        UserDefaults.standard.set(self.usernameTF.text!, forKey: "username")
                        let alertController = UIAlertController(title: "Message", message: response.result.value, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction)in  self.navigationController?.popToRootViewController(animated: true)}))
                        self.present(alertController, animated: true, completion: nil)
                        UIApplication.shared.registerForRemoteNotifications();
                        
                    }else{
                        let alertController = UIAlertController(title: "Message", message: response.result.value, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                case .failure(let error):
                    break
                }
    }
        
    }
    
    func getUserId(){
        Alamofire.request(server + "user/getUserId", method: .get).responseString { response in
            print("Get User Id: \(response.result.value!)")
            UserDefaults.standard.set(response.result.value!, forKey: "userId")
            }
        }
    }



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
