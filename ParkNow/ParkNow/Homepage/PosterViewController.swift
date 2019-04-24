//
//  PosterViewController.swift
//  ParkNow
//
//  Created by christy on 21/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import Alamofire
import SwiftyJSON

class PosterViewController: UIViewController {
    var mallId:String = ""
    var mallName:String = ""
    var district:String = ""
    var address:String = ""
    var contact:Int = 0
    var poster:String = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    //    var lots:Int = 0
    var realmResults:Results<Mall>?
    
    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var mallBtn: UIButton!
    @IBOutlet var districtLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var contactBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setLabel()
        self.setPosterImageView()
    }
    
    private func setLabel(){
        self.mallBtn.setTitle( self.mallName, for: .normal)
        self.districtLabel.text = district
        self.addressLabel.text = address
        self.contactBtn.setTitle(String(contact), for: .normal)
    }
    
    @IBAction func contactBtnClicked(_ sender: Any) {
        guard let number = URL(string: "tel://" + String(self.contact)) else { return }
        UIApplication.shared.open(number)
    }
    
    private func setPosterImageView(){
        if(self.poster == ""){
            self.posterImageView.image = UIImage(named: "noPoster")
        }else{
            Alamofire.request(self.poster).responseData {
                response in
                if let data = response.result.value {
                    self.posterImageView.image = UIImage(data: data)
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMall" {
            if let viewController = segue.destination as? MallDetailViewController {
                viewController.mallId =  self.mallId
                viewController.latitude =  self.latitude
                viewController.longitude =  self.longitude
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

