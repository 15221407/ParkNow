//
//  MyAccountViewController.swift
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
import CoreImage

class MyAccountViewController: UIViewController {
    @IBOutlet var currentPointLabel: UILabel!
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet var helloLabel: UILabel!
    @IBOutlet var logOutbtn: UIButton!
    @IBOutlet var myPointView: UIView!
    var currentPoint:String = ""
    var currentBrightness = UIScreen.main.brightness;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentBrightness = UIScreen.main.brightness
        self.setUpUI()
    }
    
    private func setUpUI(){
        self.setUpButton()
        self.setUpLabel()
        self.myPointView.layer.borderWidth = 1
        self.myPointView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }
    
    private func setUpLabel(){
        if(UserDefaults.standard.string(forKey: "username") != nil){
            self.getPoint()
            var username = UserDefaults.standard.string(forKey: "username")
            self.helloLabel.text = username!
            self.currentPointLabel.text = self.currentPoint
            self.currentPointLabel.isHidden = false;
            self.signInBtn.isHidden = true;
            self.logOutbtn.isHidden = false;
        }else{
            self.helloLabel.text = "Visitor"
            self.signInBtn.isHidden = false;
            self.currentPointLabel.isHidden = true;
            self.logOutbtn.isHidden = true;
        }
    }
    
    func setUpButton(){
        if UserDefaults.standard.string(forKey: "username") != nil {
            self.logOutbtn.setTitle("Sign Out", for: .normal)
            self.logOutbtn.isHidden = false
            self.signInBtn.isHidden = true
        } else if UserDefaults.standard.string(forKey: "username") == nil {
            self.signInBtn.setTitle("Sign In", for: .normal)
            self.signInBtn.isHidden = false
            self.logOutbtn.isHidden = true
        }
    }
    
    
    func getPoint() {
        Alamofire.request(server + "member/getPoint", method: .get).responseString { response in
            print("Get Points: \(response.result.value ?? "No data")")
            switch response.result{
            case .success(let value):
                self.currentPoint = value
                self.currentPointLabel.text = self.currentPoint
            case .failure(let error):
                self.currentPoint = "0"
                break
            }
        }
        
    }
    @IBAction func accountLogout(_ sender: Any) {
        Alamofire.request(server + "user/logout", method: .get).responseString { response in
            print("Response String: \(response.result.value ?? "No data")")
            switch response.result{
            case .success(let value):
                let alertController = UIAlertController(title: "Message", message: "Logout successfully.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                UserDefaults.standard.set(nil, forKey: "username")
                self.setUpButton()
                self.setUpLabel()
            case .failure(let error):
                break
                
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

}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
}
