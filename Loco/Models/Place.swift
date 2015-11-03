//
//  Place.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/2/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import Foundation

struct Place {
    let latitude: Double
    let longitude: Double
    let name: String
    let type: PlaceType
    
    static func typeWithString(type: String) -> PlaceType{
        switch (type) {
        case "food":
            return .Food
        case "restaurant":
            return .Food
        case "cafe":
            return .Cafe
        case "bakery":
            return .Bakery
        case "bar":
            return .Bar
        case "grocery_or_supermarket":
            return .Grocery
        default:
            return .Misc
        }
    }
    
    static func typeFromTypes(types: [String]) -> PlaceType {
        if types.contains("cafe") {
            return .Cafe
        }
        if types.contains("bar") {
            return .Bar
        }
        if types.contains("bakery") {
            return .Bakery
        }
        if types.contains("grocery_or_supermarket") {
            return .Grocery
        }
        if types.contains("food") || types.contains("restaurant") {
            return .Food
        }
        return .Misc
    }
}

enum PlaceType {
    case Food
    case Cafe
    case Bakery
    case Bar
    case Grocery
    case Misc // default
    
    
}