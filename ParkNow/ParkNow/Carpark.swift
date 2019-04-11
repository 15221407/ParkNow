//
//  Carpark.swift
//  ParkNow
//
//  Created by christy on 10/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import Foundation
import RealmSwift

class Carpark: Object {
    let id = RealmOptional<Int>()
    @objc dynamic var mallId: String? = nil
    @objc dynamic var mallName: String? = nil
    @objc dynamic var carparkId: String? = nil
    @objc dynamic var carparkName: String? = nil
    @objc dynamic var district: String? = nil
    @objc dynamic var lots: Int = 0
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var parkingFee: Int = 0
    @objc dynamic var peakHourFee: Int = 0
}
