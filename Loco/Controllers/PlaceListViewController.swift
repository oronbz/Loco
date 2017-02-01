//
//  PlacesViewController.swift
//  Loco
//
//  Created by Oron Ben Zvi on 11/3/15.
//  Copyright © 2015 Oron Ben Zvi. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class PlaceListViewController: UIViewController {
    
    weak var delegate: PlaceListDelegate?
    var places = [Place]()
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = places[indexPath.row]
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = place.name
        
        var image: UIImage!
        switch place.type {
        case .bakery:
            image = UIImage(named: "bakery")
        case .bar:
            image = UIImage(named: "bar")
        case .cafe:
            image = UIImage(named: "cafe")
        case .grocery:
            image = UIImage(named: "grocery_or_supermarket")
        case .food:
            image = UIImage(named: "restaurant")
        case .misc:
            image = UIImage(named: "misc")
        }
        cell.imageView?.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            delegate?.placeListViewController(self, didSelectPlace: places[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
        
    }
}
