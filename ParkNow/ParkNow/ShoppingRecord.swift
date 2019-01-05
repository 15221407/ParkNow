//
//  ShoppingRecord.swift
//  ParkNow
//
//  Created by christy on 5/1/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import Foundation
import RealmSwift

class ShoppingRecord: Object {
    let id = RealmOptional<Int>()
    @objc dynamic var mallName: String? = nil
    @objc dynamic var shopName: String? = nil
    @objc dynamic var consumption: String? = nil
    @objc dynamic var point: String? = nil
}

