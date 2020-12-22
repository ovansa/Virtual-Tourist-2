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

let lightBlueColor = UIColor(displayP3Red: 3/255, green: 169/255, blue: 244/255, alpha: 1)

class MapViewController: UIViewController {
    //MARK:- Variable definitions for UI Components
    var mapView: MKMapView = {
        var map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let showView: UIView = {
       let view = UIView()
        view.backgroundColor = lightBlueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let showViewText: UILabel = {
       let label = UILabel()
        label.text = "Touch and hold a location on the map to drop a pin"
        label.textColor = .white
        label.font = UIFont(name: "Avenir-Heavy", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationManager = CLLocationManager()
    var userCurrentLocation: CLLocationCoordinate2D?
    
    var pins: Results<Pins>?
    
    //MARK:- Main Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        pins = RealmHelper.retrievePins()
        populateMapWithPins(with: pins)
        hintCheck()
        mapView.delegate = self
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        setupMap()
//        pins = RealmHelper.retrievePins()
//        populateMapWithPins(with: pins)
//        hintCheck()
//    }
    
    //MARK:- Hint Methods
    private func hintCheck() {
        if pins!.isEmpty {
            showHint()
            hideHint()
        } else {
            showView.isHidden = true
        }
    }
    
    private func showHint() {
        showView.isHidden = true
        UIView.animate(withDuration: 1.0) {
            self.showView.isHidden = false
            self.showView.layoutIfNeeded()
        }
    }
    
    private func hideHint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.animate(withDuration: 1.0) {
               self.showView.isHidden = true
                self.showView.layoutIfNeeded()
            }
        }
     }
    
    //MARK:- Setup Map View
    private func setupMap() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        initiateFetchingCurrentLocation()
        hideNavigationBar()
        setupMapCenter()
        addAPinOnMap()
        setupHintView()
    }
    
    func setupHintView() {
        view.addSubview(showView)
        NSLayoutConstraint.activate([
            showView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            showView.heightAnchor.constraint(equalToConstant: 80.0),
            showView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            showView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ])
        
        showView.addSubview(showViewText)
        NSLayoutConstraint.activate([
            showViewText.centerXAnchor.constraint(equalTo: showView.centerXAnchor),
            showViewText.centerYAnchor.constraint(equalTo: showView.centerYAnchor, constant: 20.0)
        ])
    }

    func hideNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    private func initiateFetchingCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupMapCenter() {
        if let region = SaveMap.shared.retrieveMapRegion() {
            let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude), span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta, longitudeDelta: region.span.longitudeDelta))
            mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    
    //MARK:- Add and Populate Map with Pins
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
            RealmHelper.savePin(pin: pin)
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
