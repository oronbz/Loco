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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let place = places[indexPath.row]
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = place.name
        
        var image: UIImage!
        switch place.type {
        case .Bakery:
            image = UIImage(named: "bakery")
        case .Bar:
            image = UIImage(named: "bar")
        case .Cafe:
            image = UIImage(named: "cafe")
        case .Grocery:
            image = UIImage(named: "grocery_or_supermarket")
        case .Food:
            image = UIImage(named: "restaurant")
        case .Misc:
            image = UIImage(named: "misc")
        }
        cell.imageView?.image = image
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if delegate != nil {
            delegate?.placeListViewController(self, didSelectPlace: places[indexPath.row])
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
}
