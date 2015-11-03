//
//  PlaceAnnotation.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/2/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import UIKit
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var type: PlaceType
    
    init(coordinate: CLLocationCoordinate2D, title: String, type: PlaceType) {
        self.coordinate = coordinate
        self.title = title
        self.type = type
    }
}