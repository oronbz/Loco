//
//  PlaceAnnotationView.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/2/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import UIKit
import MapKit

class PlaceAnnotationView: MKAnnotationView {

    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let placeAnnotation = self.annotation as? PlaceAnnotation {
            
            switch (placeAnnotation.type) {
            case .Bakery:
                image = UIImage(named: "bakery_pin")
            case .Bar:
                image = UIImage(named: "bar_pin")
            case .Cafe:
                image = UIImage(named: "cafe_pin")
            case .Grocery:
                image = UIImage(named: "grocery_or_supermarket_pin")
            case .Food:
                image = UIImage(named: "restaurant_pin")
            case .Misc:
                image = UIImage(named: "misc_pin")
                
            }
        }
    }
    


}

