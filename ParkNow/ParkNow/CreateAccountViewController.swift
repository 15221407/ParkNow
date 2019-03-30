//
//  CreateAccountViewController.swift
//  ParkNow
//
//  Created by christy on 27/3/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift

class CreateAccountViewController: UIViewController {
    @IBOutlet var pwWarningLabel: UILabel!
    @IBOutlet var nameWarningLabel: UILabel!
    @IBOutlet var conWarningLabel: UILabel!
    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var confirmPasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setUpLabel()
    }
    
    private func setUpLabel(){
        self.pwWarningLabel.isHidden = true;
        self.nameWarningLabel.isHidden = true;
        self.conWarningLabel.isHidden = true;
        self.usernameTF.layer.borderColor = UIColor( red: 1, green: 1 , blue:1, alpha: 1.0 ).cgColor
        self.passwordTF.layer.borderColor = UIColor( red: 1, green: 1 , blue:1, alpha: 1.0 ).cgColor
        self.confirmPasswordTF.layer.borderColor = UIColor( red: 1, green: 1 , blue:1, alpha: 1.0 ).cgColor
    }
    
    @IBAction func createMyAccount(_ sender: Any) {
        self.setUpLabel()
        
        if self.usernameTF.text != "" && self.passwordTF.text != "" && self.confirmPasswordTF.text != ""{
            if self.confirmPasswordTF.text == self.passwordTF.text {
                self.createMember()
            }else{
                self.pwWarningLabel.isHidden = false;
                self.pwWarningLabel.text = "Cannot match with Confirmed Password"
                self.passwordTF.layer.borderColor = UIColor( red: 1, green: 0 , blue:0, alpha: 1.0 ).cgColor
                self.conWarningLabel.isHidden = false;
                self.conWarningLabel.text = "Cannot match with Password"
                self.confirmPasswordTF.layer.borderColor = UIColor( red: 1, green: 0 , blue:0, alpha: 1.0 ).cgColor
            }
            
        }else {
            if self.usernameTF.text == "" {
                self.nameWarningLabel.isHidden = false;
                self.nameWarningLabel.text = "Please fill in."
                self.usernameTF.layer.borderColor = UIColor( red: 1, green: 0 , blue:0, alpha: 1.0 ).cgColor
            }
            if self.passwordTF.text == "" {
                self.pwWarningLabel.isHidden = false;
                self.pwWarningLabel.text = "Please fill in."
                self.passwordTF.layer.borderColor = UIColor( red: 1, green: 0 , blue:0, alpha: 1.0 ).cgColor
            }
            if self.confirmPasswordTF.text == "" {
                self.conWarningLabel.isHidden = false;
                self.conWarningLabel.text = "Please fill in."
                self.confirmPasswordTF.layer.borderColor = UIColor( red: 1, green: 0 , blue:0, alpha: 1.0 ).cgColor
            }
        }
    }
    
    private func createMember(){
        let parameters : Parameters = ["username": usernameTF.text! , "password": passwordTF.text!]
        
        Alamofire.request(server + "member/createNewAccount", method: .post, parameters: parameters)
            .responseString { response in
                print("Create New Account: \(response.result.value ?? "No data")")
                switch response.result{
                    
                case .success(let value):
                    var json:JSON = JSON(value);
                    if(json == "Successfully Created!"){
                        self.getUserId()
                        UserDefaults.standard.set(self.usernameTF.text!, forKey: "username")
                        UIApplication.shared.registerForRemoteNotifications();
                        let alertController = UIAlertController(title: "Message", message: response.result.value, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction)in  self.navigationController?.popToRootViewController(animated: true)}))
                        self.present(alertController, animated: true, completion: nil)
                        
                    }else if (json == "existed"){
                        self.nameWarningLabel.isHidden = false;
                        self.nameWarningLabel.text = "The username " + self.usernameTF.text! + " already exists."
                        self.usernameTF.layer.borderColor = UIColor( red: 1, green: 0 , blue:0, alpha: 1.0 ).cgColor
                    }
                case .failure(let error):
                    break
                    
                }
        }
    }
   
    private func getUserId(){
        Alamofire.request(server + "user/getUserId", method: .get).responseString { response in
            print("Get User Id: \(response.result.value!)")
            UserDefaults.standard.set(response.result.value!, forKey: "userId")
        }
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

