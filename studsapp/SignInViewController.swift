//
//  SignInViewController.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-05-30.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // User authorized before
            GIDSignIn.sharedInstance().signInSilently()
        } else {
//            GIDSignIn.sharedInstance().signIn()
        }
        
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if user != nil {
                self.syncUserDetails()
                self.performSegue(withIdentifier: "loggedInShareAdd", sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func syncUserDetails() {
        let databaseRef = Database.database().reference()
        let key = Auth.auth().currentUser!.providerData[0].uid
        let post = [
            "email": Auth.auth().currentUser?.email ?? "",
            "name": Auth.auth().currentUser?.displayName ?? "",
            "picture": String(describing: Auth.auth().currentUser!.photoURL!)
            ] as [String : Any]
        
        let childUpdates = ["/users/\(String(describing: key))": post]
        databaseRef.updateChildValues(childUpdates)

    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

