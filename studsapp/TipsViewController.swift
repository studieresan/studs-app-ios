//
//  SecondViewController.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-05-30.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import UIKit
import Firebase

class TipsViewController: UIViewController {
    var databaseRef: DatabaseReference!
    fileprivate var _refHandle1: DatabaseHandle!
    fileprivate var _refHandle2: DatabaseHandle!
    fileprivate var _refHandle3: DatabaseHandle!
    fileprivate var _refHandle4: DatabaseHandle!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        databaseRef = Database.database().reference()
        _refHandle1 = databaseRef.child("static").child("location").queryEqual(toValue: "New York", childKey: "city").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
            // let loc = CLLocation(latitude: CLLocationDegrees(snapDict["latitude"] as! Double), longitude: CLLocationDegrees(snapDict["longitude"] as! Double))
            //let newLocation = TipLocation()

            //Location(key: snapshot.key, message: snapDict["message"] as! String, longitude: snapDict["lng"] as! Double, latitude: snapDict["lat"] as! Double, location: loc, uid: (snapDict["user"] as? String ?? ""), timestamp: (timestamp ?? 0.0), category: (snapDict["category"] as? String ?? ""))
            
           // strongSelf.locationData.locations.insert(newLocation, at: 0)

        })

        _refHandle2 = databaseRef.child("static").child("location").queryEqual(toValue: "Vancouver", childKey: "city").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
        })

        _refHandle3 = databaseRef.child("static").child("location").queryEqual(toValue: "Portland", childKey: "city").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
        })

        _refHandle4 = databaseRef.child("static").child("location").queryEqual(toValue: "San Francisco", childKey: "city").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        if (_refHandle1) != nil {
            databaseRef.child("static").child("location").queryEqual(toValue: "New York", childKey: "city").removeObserver(withHandle: _refHandle1)
        }
        if (_refHandle2) != nil {
            databaseRef.child("static").child("location").queryEqual(toValue: "Vancouver", childKey: "city").removeObserver(withHandle: _refHandle2)
        }
        if (_refHandle3) != nil {
            databaseRef.child("static").child("location").queryEqual(toValue: "Portland", childKey: "city").removeObserver(withHandle: _refHandle3)
        }
        if (_refHandle4) != nil {
            databaseRef.child("static").child("location").queryEqual(toValue: "San Francisco", childKey: "city").removeObserver(withHandle: _refHandle4)
        }
    }
}

