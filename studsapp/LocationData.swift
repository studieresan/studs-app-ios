//
//  LocationData.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-06-08.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import Foundation

class LocationData {
    var locations = [Location]()
    var users = [String: User]()
    
    static let shared = LocationData()
    
}
