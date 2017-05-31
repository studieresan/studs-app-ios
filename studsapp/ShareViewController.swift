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

class ShareViewController: UITableViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var longitudeDetailLabel: UILabel!
    @IBOutlet weak var latitudeDetailLabel: UILabel!
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            "message": messageTextField.text ?? ""
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
