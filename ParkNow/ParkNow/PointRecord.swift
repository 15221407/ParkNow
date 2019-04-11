//
//  PointRecord.swift
//  ParkNow
//
//  Created by christy on 10/4/2019.
//  Copyright © 2019 christy. All rights reserved.
//

import Foundation
import RealmSwift

class PointRecord: Object {
    let id = RealmOptional<Int>()
    @objc dynamic var mallName: String? = nil
    @objc dynamic var type: String? = nil
    @objc dynamic var amount: Int = 0
    @objc dynamic var actionAt: String? = nil
}
