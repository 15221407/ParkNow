//
//  MapMarkerWindow.swift
//  ParkNow
//
//  Created by christy on 22/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit

protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: NSDictionary)
}

class MapMarkerWindow: UIView {
    
    
    @IBOutlet weak var MallLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var lotsLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    weak var delegate: MapMarkerDelegate?
    var spotData: NSDictionary?
    
    @IBAction func didTapInfoButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: spotData!)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}
