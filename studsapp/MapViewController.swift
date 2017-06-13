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
    fileprivate var _refHandle1: DatabaseHandle!
    fileprivate var _refHandle2: DatabaseHandle!
    fileprivate var _refHandle3: DatabaseHandle!
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
        
        _refHandle1 = databaseRef.child("users").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
            
            let newUser = User(name: snapDict["name"] as! String, email: snapDict["email"] as! String, picture: snapDict["picture"] as! String)
            strongSelf.locationData.users[snapshot.key] = newUser
        })
        // Listen for new shares
        _refHandle2 = databaseRef
            .child("locations")
            .queryOrdered(byChild: "timestamp")
            .queryStarting(atValue: Date().timeIntervalSince1970 - 3600)
            .observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                guard let strongSelf = self else { return }
                let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
                let loc = CLLocation(latitude: CLLocationDegrees(snapDict["lat"] as! Double), longitude: CLLocationDegrees(snapDict["lng"] as! Double))
                let timestamp = snapDict["timestamp"] as? Double
                let newLocation = Location(key: snapshot.key, message: snapDict["message"] as! String, longitude: snapDict["lng"] as! Double, latitude: snapDict["lat"] as! Double, location: loc, uid: (snapDict["user"] as? String ?? ""), timestamp: (timestamp ?? 0.0), category: (snapDict["category"] as? String ?? ""))
            
                newLocation.setPlacemark()
                
                strongSelf.locationData.locations.insert(newLocation, at: 0)
                strongSelf.addPin(location: newLocation)
            })

        _refHandle3 = databaseRef.child("static").child("locations").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String:AnyObject] ?? [:]
            // let loc = CLLocation(latitude: CLLocationDegrees(snapDict["latitude"] as! Double), longitude: CLLocationDegrees(snapDict["longitude"] as! Double))
            let newLocation = TipLocation(name: (snapDict["name"] as? String ?? ""), address: (snapDict["address"] as? String ?? ""), category: (snapDict["category"] as? String ?? ""), city: (snapDict["city"] as? String ?? ""), daynight: (snapDict["daynight"] as? String ?? ""), description: (snapDict["description"] as? String ?? ""), latitude: snapDict["latitude"] as? Double, longitude: snapDict["longitude"] as? Double)
            
            if snapDict["city"] != nil {
                switch snapDict["city"] as! String {
                case "New York":
                    strongSelf.locationData.newYorkTips.append(newLocation)
                case "Vancouver":
                    strongSelf.locationData.vancouverTips.append(newLocation)
                case "Portland":
                    strongSelf.locationData.portlandTips.append(newLocation)
                case "San Francisco":
                    strongSelf.locationData.sanFranciscoTips.append(newLocation)
                default:
                    break
                }

                strongSelf.addPin(location: newLocation)
            }
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
        if (_refHandle1) != nil {
            databaseRef.child("locations").removeObserver(withHandle: _refHandle1)
        }
        if (_refHandle2) != nil {
            databaseRef.child("users").removeObserver(withHandle: _refHandle2)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotation is CustomAnnotation {
            let identifier = "MyPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.image = UIImage(named: (annotation as! CustomAnnotation).imageName)
                
                let detailButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = detailButton
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        } else {
            let identifier = "regular"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }

            
            view.pinTintColor = MKPinAnnotationView.redPinColor()
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! UserAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }

    
    func addPin(location: Location) {
        var timeDiff = location.timestamp + 3600 - Date().timeIntervalSince1970

        if(timeDiff > 0) {
            let user = locationData.users[location.uid]
            let annotation = UserAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotation.title = user?.name
            annotation.subtitle = location.message
            map.addAnnotation(annotation)
            
            // Annotation removal timer
            let timer : DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timer.scheduleRepeating(deadline: .now(), interval: .seconds(600), leeway: .seconds(5))
            timer.setEventHandler {
                timeDiff = location.timestamp + 3600 - Date().timeIntervalSince1970

                let annotationView = self.map.view(for: annotation)
                if annotationView != nil {
                    annotationView!.alpha = CGFloat((timeDiff)/3600)
                    if annotationView!.alpha < 0.1 {
                        self.map.removeAnnotation(annotation)
                        if let index = self.locationData.locations.index(of: location) {
                            self.locationData.locations.remove(at: index)
                        }
                        
                        timer.cancel()
                    }
                }
            }
            timer.resume()
        }
    }
    
    func addPin(location: TipLocation) {
        if location.longitude != nil {
            var annotation: MKPointAnnotation
            switch location.category {
            case "living":
                annotation = CustomAnnotation(imageName: "home")
//            case "eat":
//                annotation = CustomAnnotation(imageName: "dining-room")
//            case "drink":
//                annotation = CustomAnnotation(imageName: "bar")
//            case "shopping":
//                annotation = CustomAnnotation(imageName: "shopping-bag")
//            case "activity":
//                annotation = CustomAnnotation(imageName: "dining-room")
            default:
                annotation = UserAnnotation()
            }
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
            annotation.title = location.name
            map.addAnnotation(annotation)

        }
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

