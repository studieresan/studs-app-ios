//
//  TipLocation.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-06-12.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import Foundation
import CoreLocation

class TipLocation: Equatable {
    var name: String
    var address: String
    var category: String
    var city: String
    var daynight: String
    var description: String
    var latitude: Double
    var longitude: Double
    
    
    init(name: String, address: String, category: String, city: String, daynight: String, description: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.category = category
        self.city = city
        self.daynight = daynight
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func == (lhs: TipLocation, rhs: TipLocation) -> Bool { return lhs === rhs }
}
