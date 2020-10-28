//
//  MapViewController.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 27/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class MapViewController: UIViewController {
    var mapView: MKMapView = {
        var map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    
    var pins: Results<Pins>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self
        
        pins = retrievePins()
        populateMapWithPins(with: pins)
    }
    
    private func savePin(pin: Pins) {
        do {
            try realm.write {
                realm.add(pin)
                print("Pin is saved")
            }
        } catch {
            print("Error saving pin: \(error)")
        }
    }
    
    private func retrievePins() -> Results<Pins>? {
        let retrievedPins = realm.objects(Pins.self)
        
        return retrievedPins
    }
    
    //MARK: - Setup Map Method
    
    private func setupMap() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupMapCenter()
        addAPinOnMap()
    }
    
    func setupMapCenter() {
        if let region = SaveMap.shared.retrieveMapRegion() {
            let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude), span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta, longitudeDelta: region.span.longitudeDelta))
            mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    private func addAPinOnMap() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPress.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPress)
    }
    
    @objc private func addAnnotation(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let location = press.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let pin = Pins()
            pin.latitude = annotation.coordinate.latitude
            pin.longitude = annotation.coordinate.longitude
            pin.id = String(annotation.coordinate.latitude) + String(annotation.coordinate.longitude)
            savePin(pin: pin)
        }
    }
    
    private func populateMapWithPins(with pinResult: Results<Pins>?) {
        if let thePins = pinResult {
            for singlePin in thePins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: singlePin.latitude, longitude: singlePin.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
}
