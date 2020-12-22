//
//  Pins.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 28/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import RealmSwift

class Pins: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var numberOfUrls: Int = 0
    let imageUrls = List<Images>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
