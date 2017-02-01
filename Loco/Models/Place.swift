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
    
    static func typeWithString(_ type: String) -> PlaceType{
        switch (type) {
        case "food":
            return .food
        case "restaurant":
            return .food
        case "cafe":
            return .cafe
        case "bakery":
            return .bakery
        case "bar":
            return .bar
        case "grocery_or_supermarket":
            return .grocery
        default:
            return .misc
        }
    }
    
    static func typeFromTypes(_ types: [String]) -> PlaceType {
        if types.contains("cafe") {
            return .cafe
        }
        if types.contains("bar") {
            return .bar
        }
        if types.contains("bakery") {
            return .bakery
        }
        if types.contains("grocery_or_supermarket") {
            return .grocery
        }
        if types.contains("food") || types.contains("restaurant") {
            return .food
        }
        return .misc
    }
}

enum PlaceType {
    case food
    case cafe
    case bakery
    case bar
    case grocery
    case misc // default
    
    
}
