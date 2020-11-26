//
//  Images.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 28/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import RealmSwift

class Images: Object {
    @objc dynamic var directoryURLOFSavedImage: String = ""
    let parentPin = LinkingObjects(fromType: Pins.self, property: "imageUrls")
    
    override static func primaryKey() -> String? {
        return "directoryURLOFSavedImage"
    }
}

