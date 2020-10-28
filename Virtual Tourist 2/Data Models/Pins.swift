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
    let imageUrls = List<Images>()
}

// 1. Create models to store pins
// 2. Create model to store image urls
// 3. Establish a relationship between pins and image urls
// 4. Create method to store pins
// 5. Create method to retrieve pins

