//
//  MallViewController.swift
//  ParkNow
//
//  Created by christy on 20/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift

var server = "http://192.168.0.106:1337/" ;

class MallViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate{

    var realmResults:Results<Mall>?
    @IBOutlet var collectionView: UICollectionView!

  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.setUpCollectionView()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMall()
    }
    
    func setUpCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
//        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    
    func getMall(){
        let realm = try! Realm()
        let url = server + "mall/json"
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            print("Mall info: \(response.result.value)") // response serialization result
            switch response.result {
            case .success(let value):
                let json:JSON = JSON(value);
                
                // Delete all objects from the realm
                try! realm.write {
                    realm.deleteAll()
                }
                for index in 0..<json.count {
                    let mall = Mall()
                    mall.mallId = json[index]["mallId"].stringValue
                    mall.name = json[index]["mallName"].stringValue
                    mall.district = json[index]["district"].stringValue
                    mall.address = json[index]["address"].stringValue
                    mall.contact = json[index]["contact"].intValue
                    mall.longitude = json[index]["longitude"].doubleValue
                    mall.latitude = json[index]["latitude"].doubleValue
                    mall.poster = json[index]["poster"].stringValue
                    
                    try! realm.write {
                        realm.add(mall)
                    }
                }
                self.realmResults = realm.objects(Mall.self)
                self.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPoster" {
            if let viewController = segue.destination as? PosterViewController {
                let cell = sender as! UICollectionViewCell
                let selectedIndex = self.collectionView!.indexPath(for: cell)
                viewController.mallId =  realmResults?[selectedIndex!.row].mallId as! String
                viewController.mallName =  realmResults![selectedIndex!.row].name as! String
                viewController.address =  realmResults?[selectedIndex!.row].address as! String
                viewController.poster =  realmResults?[selectedIndex!.row].poster as! String
                viewController.district =  realmResults?[selectedIndex!.row].district as! String
                viewController.longitude =  (realmResults?[selectedIndex!.row].longitude)!
                viewController.latitude =  (realmResults?[selectedIndex!.row].latitude)!
                viewController.contact =  (realmResults?[selectedIndex!.row].contact)!
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let r = realmResults {
            return r.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mallCollectionViewCell", for: indexPath) as!  mallCollectionViewCell
        
        let url = self.realmResults?[indexPath.row].poster
        
        if let unwrappedUrl = url {
            
            Alamofire.request(unwrappedUrl).responseData {
                response in
                if let data = response.result.value {
                    cell.collectionImageView.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
