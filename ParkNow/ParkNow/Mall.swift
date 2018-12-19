//
//  Mall.swift
//  ParkNow
//
//  Created by christy on 18/12/2018.
//  Copyright © 2018 christy. All rights reserved.
//

import Foundation
import RealmSwift

class Mall: Object {
    let id = RealmOptional<Int>()
    @objc dynamic var mallId: String? = nil
    @objc dynamic var name: String? = nil
    @objc dynamic var district: String? = nil
    @objc dynamic var address: String? = nil
    @objc dynamic var contact: String? = nil
    @objc dynamic var parkingFee: String? = nil
    @objc dynamic var spending: String? = nil
    @objc dynamic var poster: String? = nil
    @objc dynamic var lots: Int = 0
    @objc dynamic var details: String? = nil
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
}

