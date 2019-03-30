//
//  Car.swift
//  ParkNow
//
//  Created by christy on 29/3/2019.
//  Copyright © 2019 christy. All rights reserved.
//
import Foundation
import RealmSwift

class Car: Object {
    let id = RealmOptional<Int>()
    @objc dynamic var uid: String? = nil
    @objc dynamic var licensePlate: String? = nil
}
