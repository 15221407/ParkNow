//
//  MyCarViewController.swift
//  ParkNow
//
//  Created by christy on 20/1/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit

class MyCarViewController: UIViewController {
    @IBOutlet var registerBtn: UIButton!
    @IBOutlet var prepayBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpButton()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpButton()
    }
    
    func setUpButton(){
        //not allow users register their car and prepay the parking fee without login
        if(UserDefaults.standard.string(forKey: "username") != nil){
            self.registerBtn.isHidden = false;
            self.prepayBtn.isHidden = false;
        }else{
            self.registerBtn.isHidden = true;
            self.prepayBtn.isHidden = true;
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
