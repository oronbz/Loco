//
//  PlacesListDelegate.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/3/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import Foundation

protocol PlaceListDelegate {
    func placeListViewController(controller: PlaceListViewController, didSelectPlace place: Place)
}