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
    func autocomplete(input: String, completion: @escaping (_ results: [Prediction], _ error: String?) -> Void) {
        let params =   ["input": input,
                        "key": Config.googleAPIKey];
        
        Alamofire.request(Config.googleAutocompleteUrl, method: .get, parameters: params)
            .responseJSON { response in
                //debugPrint(response)
                
                var predictionResults = [Prediction]()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googleAutocompleteUrl)")
                    print(response.result.error!)
                    completion(predictionResults, response.result.error?.localizedDescription)
                    return
                }
                
                if let json: Any = response.result.value {
                    // handle the results as JSON, without a bunch of nested if loops
                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(predictionResults, errorMessage)
                        return
                    }
                    
                    if let predictions = jsonObject["predictions"].array {
                        predictionResults = predictions.map({ predictionJson -> Prediction in
                            return Prediction(description: predictionJson["description"].stringValue, placeId: predictionJson["place_id"].stringValue)
                        })
                    }
                }
                completion(predictionResults, nil)
                
        }
        
    }
    
    func placesNearLatitude(_ latitude: Double, longitude: Double, completion: @escaping (_ results: [Place], _ error: String?) -> Void) {
        let params =   ["location": "\(latitude),\(longitude)",
                        "radius": "500",
                        "key": Config.googleAPIKey,
                        "types": "food|restaurant|bar|bakery|grocery_or_supermarket"];
        Alamofire.request(Config.googlePlacesUrl, method: .get, parameters: params)
            .responseJSON { response in
                //debugPrint(response)
                var placeResults = [Place]()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googlePlacesUrl)")
                    print(response.result.error!)
                    completion(placeResults, response.result.error?.localizedDescription)
                    return
                }
                
                if let json: Any = response.result.value {

                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(placeResults, errorMessage)
                        return
                    }
                    
                    if let results = jsonObject["results"].array {
                        for result in results {
                            placeResults.append(self.placeWithResult(result))
                        }
                    }
                    
                }
                completion(placeResults, nil)
        }
    }
    
    func placeById(_ placeId: String, completion: @escaping (_ result: Place?, _ error: String?) -> Void) {
        let params =   ["placeid": placeId,
                        "key": Config.googleAPIKey,];
                Alamofire.request(Config.googlePlaceDetailsUrl, method: .get, parameters: params)
                    .responseJSON { response in
                //debugPrint(response)
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googlePlaceDetailsUrl)")
                    print(response.result.error!)
                    completion(nil, response.result.error?.localizedDescription)
                    return
                }
                
                if let json: Any = response.result.value {
                    
                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(nil, errorMessage)
                        return
                    }
                
                    let place = self.placeWithResult(jsonObject["result"])
                    completion(place, nil)
                    
                }
                completion(nil, nil)
        }
    }
    
    func addressByLatitude(_ latitude: Double, longitude: Double, completion: @escaping (_ result: String?, _ error: String?) -> Void) {
        let params =   ["latlng": "\(latitude),\(longitude)",
            "key": Config.googleAPIKey,];
        Alamofire.request(Config.googleGeocodeUrl, method: .get, parameters: params)
            .responseJSON { response in
                //debugPrint(response)
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on \(Config.googleGeocodeUrl)")
                    print(response.result.error!)
                    completion(nil, response.result.error?.localizedDescription)
                    return
                }
                
                if let json: Any = response.result.value {
                    
                    let jsonObject = JSON(json)
                    if jsonObject["status"] != "OK", let errorMessage = jsonObject["error_message"].string  {
                        completion(nil, errorMessage)
                        return
                    }
                    
                    let address = jsonObject["results"][0]["formatted_address"].string
                    completion(address, nil)
                    
                }
                completion(nil, nil)
        }
    }
    
    
    fileprivate func placeWithResult(_ result: JSON) -> Place {
        let latitude = result["geometry"]["location"]["lat"].doubleValue
        let longitude = result["geometry"]["location"]["lng"].doubleValue
        let name = result["name"].stringValue
        let types = result["types"].arrayObject as! [String]
        let type: PlaceType = Place.typeFromTypes(types)
        return Place(latitude: latitude, longitude: longitude, name: name, type: type)
    }
}
