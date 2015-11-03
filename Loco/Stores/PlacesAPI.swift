//
//  PlacesApi.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/2/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PlacesAPI {
    func autocomplete(input: String, completion: (results: [Prediction], error: String?) -> Void) {
        let params =   ["input": input,
                        "key": Config.googleAPIKey];
        
        Alamofire.request(.GET, Config.googleAutocompleteUrl, parameters: params)
            .responseJSON { response in
                //debugPrint(response)
                
                var predictionResults = [Prediction]()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googleAutocompleteUrl)")
                    print(response.result.error!)
                    completion(results: predictionResults, error: response.result.error?.localizedDescription)
                    return
                }
                
                if let json: AnyObject = response.result.value {
                    // handle the results as JSON, without a bunch of nested if loops
                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(results: predictionResults, error: errorMessage)
                        return
                    }
                    
                    if let predictions = jsonObject["predictions"].array {
                        predictionResults = predictions.map({ predictionJson -> Prediction in
                            return Prediction(description: predictionJson["description"].stringValue, placeId: predictionJson["place_id"].stringValue)
                        })
                    }
                }
                completion(results: predictionResults, error: nil)
                
        }
        
    }
    
    func placesNearLatitude(latitude: Double, longitude: Double, completion: (results: [Place], error: String?) -> Void) {
        let params =   ["location": "\(latitude),\(longitude)",
                        "radius": "500",
                        "key": Config.googleAPIKey,
                        "types": "food|restaurant|bar|bakery|grocery_or_supermarket"];
        Alamofire.request(.GET, Config.googlePlacesUrl, parameters: params)
            .responseJSON { response in
                //debugPrint(response)
                var placeResults = [Place]()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googlePlacesUrl)")
                    print(response.result.error!)
                    completion(results: placeResults, error: response.result.error?.localizedDescription)
                    return
                }
                
                if let json: AnyObject = response.result.value {

                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(results: placeResults, error: errorMessage)
                        return
                    }
                    
                    if let results = jsonObject["results"].array {
                        for result in results {
                            placeResults.append(self.placeWithResult(result))
                        }
                    }
                    
                }
                completion(results: placeResults, error: nil)
        }
    }
    
    func placeById(placeId: String, completion: (result: Place?, error: String?) -> Void) {
        let params =   ["placeid": placeId,
                        "key": Config.googleAPIKey,];
        Alamofire.request(.GET, Config.googlePlaceDetailsUrl, parameters: params)
            .responseJSON { response in
                //debugPrint(response)
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googlePlaceDetailsUrl)")
                    print(response.result.error!)
                    completion(result: nil, error: response.result.error?.localizedDescription)
                    return
                }
                
                if let json: AnyObject = response.result.value {
                    
                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(result: nil, error: errorMessage)
                        return
                    }
                
                    let place = self.placeWithResult(jsonObject["result"])
                    completion(result: place, error: nil)
                    
                }
                completion(result: nil, error: nil)
        }
    }
    
    func addressByLatitude(latitude: Double, longitude: Double, completion: (result: String?, error: String?) -> Void) {
        let params =   ["latlng": "\(latitude),\(longitude)",
            "key": Config.googleAPIKey,];
        Alamofire.request(.GET, Config.googleGeocodeUrl, parameters: params)
            .responseJSON { response in
                //debugPrint(response)
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googleGeocodeUrl)")
                    print(response.result.error!)
                    completion(result: nil, error: response.result.error?.localizedDescription)
                    return
                }
                
                if let json: AnyObject = response.result.value {
                    
                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(result: nil, error: errorMessage)
                        return
                    }
                    
                    let address = jsonObject["results"][0]["formatted_address"].string
                    completion(result: address, error: nil)
                    
                }
                completion(result: nil, error: nil)
        }
    }
    
    
    private func placeWithResult(result: JSON) -> Place {
        let latitude = result["geometry"]["location"]["lat"].doubleValue
        let longitude = result["geometry"]["location"]["lng"].doubleValue
        let name = result["name"].stringValue
        let types = result["types"].arrayObject as! [String]
        let type: PlaceType = Place.typeFromTypes(types)
        return Place(latitude: latitude, longitude: longitude, name: name, type: type)
    }
}