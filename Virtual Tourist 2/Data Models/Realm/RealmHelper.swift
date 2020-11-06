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
    
    //MARK: - Method to save image
    static func saveImage(image: Images) {
        do {
            try realm.write {
                realm.add(image)
            }
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    
}
