//
//  CarparkTableViewCell.swift
//  ParkNow
//
//  Created by christy on 24/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import UIKit

class CarparkTableViewCell: UITableViewCell {
    @IBOutlet var carparkLabel: UILabel!
    @IBOutlet var mallLabel: UILabel!
    @IBOutlet var lotsLabel: UILabel!
    @IBOutlet var navBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
