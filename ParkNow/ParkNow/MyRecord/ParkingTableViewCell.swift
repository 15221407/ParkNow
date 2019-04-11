//
//  ParkingTableViewCell.swift
//  ParkNow
//
//  Created by christy on 10/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit

class ParkingTableViewCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var licenseLabel: UILabel!
    @IBOutlet var carparkLabel: UILabel!
    @IBOutlet var inLabel: UILabel!
    @IBOutlet var outLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
