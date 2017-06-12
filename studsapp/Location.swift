//
//  Location.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-06-08.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import Foundation
import CoreLocation

class Location: Equatable {
    var key: String
    var message: String
    var longitude: Double
    var latitude: Double
    var location: CLLocation
    var uid: String
    var timestamp: Double
    var category: String
    
    var placemark: CLPlacemark?
    
    init(key: String, message: String, longitude: Double, latitude: Double, location: CLLocation, uid: String, timestamp: Double, category: String) {
        self.key = key
        self.message = message
        self.longitude = longitude
        self.latitude = latitude
        self.location = location
        self.uid = uid
        self.timestamp = timestamp
        self.category = category
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
    
    static func == (lhs: Location, rhs: Location) -> Bool { return lhs === rhs }
}
