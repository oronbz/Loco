//
//  CustomUserLocationAnnotation.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/3/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import UIKit
import MapKit

class CustomUserLocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
}