//
//  SaveMap.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 27/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import MapKit

class SaveMap {
    static let shared = SaveMap()
    
    init() {
        savedRegion = retrieveMapRegion()
    }
    
    var savedRegion : MKCoordinateRegion? {
        didSet {
            saveMapRegion()
        }
    }
    
    func saveMapRegion() {
        // This is called when savedRegion has a value
        if let region = savedRegion {
            print(region)
            let regions : [String : CLLocationDegrees] = [
                "latitude" : region.center.latitude,
                "longitude" : region.center.longitude,
                "latitudeDelta": region.span.latitudeDelta,
                "longitudeDelta" : region.span.longitudeDelta
            ]
            UserDefaults.standard.set(regions, forKey: "region")
        }
    }
    
    func retrieveMapRegion() -> MKCoordinateRegion? {
        if let region = UserDefaults.standard.dictionary(forKey: "region") {
            if let latitude = region["latitude"] as? CLLocationDegrees,
                let longitude = region["longitude"] as? CLLocationDegrees,
                let latitudeDelta = region["latitudeDelta"] as? CLLocationDegrees,
                let longitudeDelta = region["longitudeDelta"] as? CLLocationDegrees {
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            }
        }
        return nil
    }
}
