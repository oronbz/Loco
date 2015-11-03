//
//  ViewController.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/2/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class ViewController: UIViewController {
    
    @IBOutlet weak var placeListButton: UIButton!
    @IBOutlet weak var autocompleteTableView: UITableView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchBox: UITextField!
    let locationManager = CLLocationManager()
    let placesApi = PlacesAPI()
    
    var places = [Place]()
    var autocompleteResults = [Prediction]() {
        didSet {
            autocompleteTableView.hidden = !(autocompleteResults.count > 0)
            autocompleteTableView.reloadData()
        }
    }
    var userLocation: CLLocation?
    var customUserLocationAnnotation: CustomUserLocationAnnotation?
    var placeAnnotations = [PlaceAnnotation]()
    
    var shouldUpdateMapview = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        searchBox.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)

        setupButtons()
        
        
    }
    
    func setupButtons() {
        currentLocationButton.setFAIcon(.FAMapMarker, iconSize: 30, forState: .Normal)
        currentLocationButton.layer.cornerRadius = 0.5 * currentLocationButton.bounds.size.width
        currentLocationButton.layer.shadowRadius = 3
        currentLocationButton.layer.shadowOpacity = 0.5
        
        placeListButton.setFAIcon(.FAList, iconSize: 30, forState: .Normal)
        placeListButton.layer.cornerRadius = 0.5 * currentLocationButton.bounds.size.width
        placeListButton.layer.shadowRadius = 3
        placeListButton.layer.shadowOpacity = 0.5
    }
    
    @IBAction func goToCurrentLocation(sender: AnyObject) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        shouldUpdateMapview = true
    }
    
    func goToPlace(place: Place, setUserAnnotation: Bool) {
        removeCustomUserAnnotation()
        
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        mapView.showsUserLocation = true
        
        let title = place.name
        customUserLocationAnnotation = CustomUserLocationAnnotation(coordinate: coordinate, title: title)
        
        goToCoordinate(coordinate)
        
        if setUserAnnotation {
            mapView.addAnnotation(customUserLocationAnnotation!)
        }
    }
    
    func goToCoordinate(coordinate: CLLocationCoordinate2D) {
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        placesApi.placesNearLatitude(coordinate.latitude, longitude: coordinate.longitude) {
            results, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let errorMessage = error {
                    print(errorMessage)
                    self.errorAlert(errorMessage)
                } else {
                    self.places = results
                    self.annotateNearbyPlaces(results)
                }
                
            }
        }
        
        
    }
    
    func annotateNearbyPlaces(places: [Place]) {
        // remove all existing annotations
        mapView.removeAnnotations(placeAnnotations)
        placeAnnotations.removeAll()
        
        for place in places {
            let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let title = place.name
            let annotation = PlaceAnnotation(coordinate: coordinate, title: title, type: place.type)
            placeAnnotations.append(annotation)
            mapView.addAnnotation(annotation)
        }
    }
    
    func autocomplete(text: String) {
        placesApi.autocomplete(searchBox.text!) { results, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let errorMessage = error {
                    self.errorAlert(errorMessage)
                } else {
                    self.autocompleteResults = results
                }
            }
        }
    }
    
    func errorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func removeCustomUserAnnotation() {
        if let annotation = customUserLocationAnnotation {
            mapView.removeAnnotation(annotation)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PlaceList" {
            let destController = segue.destinationViewController as! PlaceListViewController
            destController.places = places
            destController.delegate = self
        }
    }
    
}

// MARK: textField
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(textField: UITextField) {
        if textField.text != nil && textField.text?.characters.count >= 2 {
            autocomplete(textField.text!)
        } else {
            autocompleteResults.removeAll()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        autocompleteTableView.hidden = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        autocompleteTableView.hidden = true
    }
}

//MARK: Location Manager
extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if shouldUpdateMapview {
            let userLocation = locations[0]
            let latitude = userLocation.coordinate.latitude
            let longitude = userLocation.coordinate.longitude
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            goToCoordinate(coordinate)
            mapView.showsUserLocation = true
            removeCustomUserAnnotation()
            
            placesApi.addressByLatitude(coordinate.latitude, longitude: coordinate.longitude) {
                result, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if let errorMessage = error {
                        self.errorAlert(errorMessage)
                    } else if let address = result {
                        self.searchBox.text = address
                    }
                }
            }
        }
        
        
        shouldUpdateMapview = false
    }
}


//MARK: mapView
extension ViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        var delay = 0.00;
        for av in views {
            if av is PlaceAnnotationView {
                av.layer.anchorPoint = CGPointMake(0.5, 1.0);
                av.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
                delay += 0.1
                UIView.animateWithDuration(0.45, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .CurveEaseOut, animations: {
                    av.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                    }, completion: nil)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation || annotation is CustomUserLocationAnnotation{
            let userAnnotationView = UserAnnotationView(annotation: annotation, reuseIdentifier: "User")
            userAnnotationView.canShowCallout = true
            // we always want user annotation on front
            userAnnotationView.layer.zPosition = 3
            return userAnnotationView
        }
        
        let annotationView = PlaceAnnotationView(annotation: annotation, reuseIdentifier: "Place")
        annotationView.canShowCallout = true
        return annotationView
    }
}

//MARK: tableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return autocompleteResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = autocompleteResults[indexPath.row].description
        cell.imageView?.image = UIImage(named: "search")
        cell.imageView?.layer.opacity = 0.7
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let prediction = autocompleteResults[indexPath.row]
        placesApi.placeById(prediction.placeId) {
            result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let errorMessage = error {
                    self.errorAlert(errorMessage)
                } else if let place = result {
                    self.goToPlace(place, setUserAnnotation: true)
                    self.searchBox.text = prediction.description
                    self.searchBox.resignFirstResponder()
                }
                
            }
        }
        
    }
}

//MARK: placeListDelegate
extension ViewController: PlaceListDelegate {
    func placeListViewController(controller: PlaceListViewController, didSelectPlace place: Place) {
        goToPlace(place, setUserAnnotation: false)
    }
}

