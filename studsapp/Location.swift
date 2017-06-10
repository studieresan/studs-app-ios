//
//  Location.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-06-08.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    var message: String
    var longitude: Double
    var latitude: Double
    var location: CLLocation
    var uid: String
    
    var placemark: CLPlacemark?
    
    init(message: String, longitude: Double, latitude: Double, location: CLLocation, uid: String) {
        self.message = message
        self.longitude = longitude
        self.latitude = latitude
        self.location = location
        self.uid = uid
    }
    
    func setPlacemark() {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                self.placemark = pm
            }
        })
    }
}
