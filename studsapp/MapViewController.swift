//
//  FirstViewController.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-05-30.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, LocationServiceDelegate {
    @IBOutlet weak var map : MKMapView!
    @IBOutlet var controlsContainer: UIView!
    @IBOutlet var userTrackingButton: UIButton!
    
    var locationManager: CLLocationManager!
    var databaseRef: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    var trackingMap = false
    
    var locationData = LocationData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 36, green: 32, blue: 33, alpha: 1.0)
        
        configureMap()
        configureLocationManager()
        configureDatabase()
        configureFloaty()
    }
    
    // Configuration
    func configureMap() {
        controlsContainer.layer.masksToBounds = false
        controlsContainer.layer.cornerRadius = 10 // if you like rounded corners
        controlsContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        controlsContainer.layer.shadowRadius = 2
        controlsContainer.layer.shadowOpacity = 0.25
        
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
        map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    func configureLocationManager() {
        // Foreground permission
        LocationService.sharedInstance.delegate = self
        LocationService.sharedInstance.startUpdatingLocation()
    }
    
    func configureDatabase() {
        databaseRef = Database.database().reference()
        
        _refHandle = databaseRef.child("users").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
            
            let newUser = User(name: snapDict["name"] as! String, email: snapDict["email"] as! String, picture: snapDict["picture"] as! String)
            strongSelf.locationData.users[snapshot.key] = newUser
        })
        // Listen for new shares
        _refHandle = databaseRef.child("locations").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
            let loc = CLLocation(latitude: CLLocationDegrees(snapDict["lat"] as! Double), longitude: CLLocationDegrees(snapDict["lng"] as! Double))
            let newLocation = Location(message: snapDict["message"] as! String, longitude: snapDict["lng"] as! Double, latitude: snapDict["lat"] as! Double, location: loc, uid: (snapDict["user"] as? String ?? ""))
            
            newLocation.setPlacemark()
            strongSelf.locationData.locations.insert(newLocation, at: 0)
            strongSelf.addPin(location: newLocation)
        })
    }
    
    func configureFloaty() {
//        let floaty = Floaty()
//        floaty.addItem(title: "Hello, World!")
//        floaty.paddingY = 75
//        self.view.addSubview(floaty)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "shareAdd" {
//            let dvc = segue.destination as! UINavigationController
//            if dvc.viewControllers.first.label
//        }
//    }
    

    deinit {
        if (_refHandle) != nil {
            databaseRef.child("locations").removeObserver(withHandle: _refHandle)
        }
    }
    
    // Map stuff
    // MARK: LocationService Delegate
    func tracingLocation(_ currentLocation: CLLocation){
    }

    // MARK: LocationService Delegate
    func tracingLocationDidFailWithError(_ error: NSError) {}
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        userTrackingButton.updateStateAnimated(true)
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        let follow = UIImage(named: "navigation_filled") as UIImage?
        let none = UIImage(named: "navigation") as UIImage?
        
        if(mode == MKUserTrackingMode.follow) {
            userTrackingButton.setBackgroundImage(follow, for: .normal)
        } else {
            userTrackingButton.setBackgroundImage(none, for: .normal)
        }
    }
    
    func addPin(location: Location) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.title = location.message
        map.addAnnotation(annotation)
    }
    
    func centerMap(_ center:CLLocationCoordinate2D) {
        let spanX = 0.007
        let spanY = 0.007
        let newRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(spanX, spanY))
        map.setRegion(newRegion, animated: true)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        if (Auth.auth().currentUser != nil) {
            self.performSegue(withIdentifier: "shareAdd", sender: self)
        } else {
            self.performSegue(withIdentifier: "login", sender: self)
        }
    }
    
    @IBAction func gpsButtonTapped(sender: UIButton) {
        if (map.userTrackingMode == MKUserTrackingMode.follow) {
            map.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
        } else {
            map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        }
    }
    
    @IBAction func unwindToMapView(segue:UIStoryboardSegue) { }
}

