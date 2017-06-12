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
    fileprivate var _refHandle: DatabaseHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        databaseRef = Database.database().reference()
        _refHandle = databaseRef.child("static").child("location").queryEqual(toValue: "New York", childKey: "city").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
        })
        
        _refHandle = databaseRef.child("static").child("location").queryEqual(toValue: "Portland", childKey: "city").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

