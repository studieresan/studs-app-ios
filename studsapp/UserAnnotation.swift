//
//  Place
//  studsapp
//
//  Created by Jesper Bränn on 2017-06-13.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class UserAnnotation: MKPointAnnotation {
    // annotation callout opens this mapItem in Maps app
    override init() {
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}

class CustomAnnotation: UserAnnotation {
    var imageName: String!
    
    init(imageName: String) {
        self.imageName = imageName
        
        super.init()
    }
}
