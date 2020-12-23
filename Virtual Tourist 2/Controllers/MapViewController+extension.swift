//
//  MapViewController+extension.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 27/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import MapKit

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
           let mapCenter = mapView.region
           SaveMap.shared.savedRegion = mapCenter
       }
       
       func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
           let vc = ImageAlbumController()
           let searchString = "\(view.annotation!.coordinate.latitude)" + "\(view.annotation!.coordinate.longitude)"
           
           let predicate = NSPredicate(format: "id = %@", searchString)
           let thePin = RealmHelper.realm.objects(Pins.self).filter(predicate)
    
           vc.locationAnnotation = view
           let pina = Pins()
           pina.latitude = (view.annotation?.coordinate.latitude)!
           pina.longitude = (view.annotation?.coordinate.longitude)!
           pina.id = "\(view.annotation!.coordinate.latitude)" + "\(view.annotation!.coordinate.latitude)"
           vc.location = thePin[0]
           navigationController?.pushViewController(vc, animated: true)
       }
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userCurrentLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error, \(error.localizedDescription)")
    }
}
