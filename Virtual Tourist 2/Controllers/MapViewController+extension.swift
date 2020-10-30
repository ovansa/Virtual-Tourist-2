//
//  MapViewController+extension.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 27/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import MapKit

extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userCurrentLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapCenter = mapView.region
        SaveMap.shared.savedRegion = mapCenter
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let vc = MapImagesViewController()
//        print("On tapping didSelect \(String(view.annotation?.coordinate.latitude as! Double) + String(view.annotation?.coordinate.longitude as! Double))")
        vc.locationAnnotation = view
        navigationController?.pushViewController(vc, animated: true)
    }
}
