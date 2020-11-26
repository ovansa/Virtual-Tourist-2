//
//  RealmHelper.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 05/11/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import RealmSwift

struct RealmHelper {
    static let realm = try! Realm()
    
    //MARK: - Methods to save and retrieve pins
    static func savePin(pin: Pins) {
        do {
            try realm.write {
                realm.add(pin)
            }
        } catch {
            print("Error saving pin: \(error)")
        }
    }

    static func retrievePins() -> Results<Pins>? {
        let retrievedPins = realm.objects(Pins.self)
        return retrievedPins
    }
    
    //MARK: - Save Image Method
    static func saveImage(image: Images) {
        do {
            try realm.write {
                realm.add(image)
            }
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    //MARK: - Retrieve Images Method
    static func retrieveImageURLs(_ searchString: String) -> List<Images>? {
        let thePin = RealmHelper.realm.objects(Pins.self).filter("id = %@", searchString)
        if let pin = thePin.first {
            return pin.imageUrls
        } else {
            return nil
        }
    }
}
