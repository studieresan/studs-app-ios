//
//  ShareViewController.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-05-30.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import GoogleSignIn
import CoreLocation

class ShareViewController: UITableViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var longitudeDetailLabel: UILabel!
    @IBOutlet weak var latitudeDetailLabel: UILabel!
    @IBOutlet weak var addressDetailLabel: UILabel!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    var currentLocation: CLLocation?
    var databaseRef: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        // Do any additional setup after loading the view.
        databaseRef = Database.database().reference()
        currentLocation = LocationService.sharedInstance.currentLocation
        let coordinates = currentLocation!.coordinate
        longitudeDetailLabel.text = String(describing: coordinates.longitude)
        latitudeDetailLabel.text = String(describing: coordinates.latitude)
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), completionHandler: {(placemarks, error) -> Void in
            if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                if pm.subThoroughfare != nil {
                    self.addressDetailLabel?.text =  pm.subThoroughfare! + " "
                }
                if pm.thoroughfare != nil {
                    self.addressDetailLabel?.text = self.addressDetailLabel!.text! + pm.thoroughfare!
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segmentIndexToName(index: Int) -> String {
        switch index {
        case 0:
            return "eat"
        case 1:
            return "drink"
        case 2:
            return "shopping"
        case 3:
            return "activity"
        default:
            return ""
        }
    }
    
    // MARK: - IBAction    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindSegueToMapView", sender: self)
    }
        
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let coordinates = currentLocation!.coordinate
        
        // save something
        let key = databaseRef.child("locations").childByAutoId().key
        let post = [
            "lat": coordinates.latitude,
            "lng": coordinates.longitude,
            "message": messageTextField.text ?? "",
            "user": Auth.auth().currentUser!.providerData[0].uid,
            "category": segmentIndexToName(index: categorySegmentedControl.selectedSegmentIndex),
            "timestamp": Date().timeIntervalSince1970
            ] as [String : Any]
        
        let childUpdates = ["/locations/\(key)": post]
        databaseRef.updateChildValues(childUpdates)
        
        performSegue(withIdentifier: "unwindSegueToMapView", sender: self)
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

        self.dismiss(animated: true, completion: nil)
    }
}
