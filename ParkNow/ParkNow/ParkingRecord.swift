//
//  ParkingRecord.swift
//  ParkNow
//
//  Created by christy on 10/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import Foundation
import RealmSwift

class ParkingRecord: Object {
    let id = RealmOptional<Int>()
    @objc dynamic var mallName: String? = nil
    @objc dynamic var carparkName: String? = nil
    @objc dynamic var enterAt: String? = nil
    @objc dynamic var leaveAt: String? = nil
    @objc dynamic var licensePlate: String? = nil
}
