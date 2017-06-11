//
//  DrawerPreviewContentViewController.swift
//  Pulley
//
//  Created by Brendan Lee on 7/6/16.
//  Copyright © 2016 52inc. All rights reserved.
//

import UIKit
import Pulley
import Firebase
import CoreLocation
import Kingfisher

class DrawerContentViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var gripperView: UIView!
    var locationData = LocationData.shared
    lazy var geocoder = CLGeocoder()

    //@IBOutlet var seperatorHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        gripperView.layer.cornerRadius = 2.5
        //seperatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DrawerContentViewController: PulleyDrawerViewControllerDelegate {
    
    
    func collapsedDrawerHeight() -> CGFloat {
        return 92.0
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        return 264.0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        tableView.isScrollEnabled = drawer.drawerPosition == .open
        
        // Reload data
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if drawer.drawerPosition != .open {
            //            searchBar.resignFirstResponder()
        }
    }
}

extension DrawerContentViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
}

extension DrawerContentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationData.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
    
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DrawerContentViewController.longTap))
        cell.addGestureRecognizer(longGesture)
        
        if (indexPath.row < locationData.locations.count) {
            let location = locationData.locations[indexPath.row]
            let user = locationData.users[location.uid]
            if user != nil {
                let url = URL(string: user!.picture)
                cell.nameLabel?.text = user!.name
                cell.avatarView.kf.setImage(with: url)
            } else {
                cell.nameLabel?.text = "Studsboll"
            }
            
            cell.messageLabel?.text = location.message
            
            if location.placemark != nil {
                var address = "@"
                address = address + " " + (location.placemark!.subThoroughfare ?? "")
                address = address + " " + (location.placemark!.thoroughfare ?? "")
                address = address + ", " + (location.placemark!.subLocality ?? "")
                
                cell.locationLabel?.text = address
            }
            
            cell.longitude = location.longitude
            cell.latitude = location.latitude
            
            if location.timestamp > 0 {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "sv_SE")
                formatter.timeStyle = .short
                cell.dateLabel?.text = formatter.string(from: Date(timeIntervalSince1970: location.timestamp))
            }
            
            switch location.category {
                case "drink":
                    cell.statusImage.image = UIImage(named: "bar")
                case "eat":
                    cell.statusImage.image = UIImage(named: "dining-room")
                case "shopping":
                    cell.statusImage.image = UIImage(named: "shopping-bag")
                case "activity":
                    cell.statusImage.image = UIImage(named: "ferris-wheel")
                default:
                    break;
            }
            
        }

        return cell
    }
    
    func longTap(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else { return }
        
        if let recognizerView = gestureRecognizer.view,
            let recognizerSuperView = recognizerView.superview, recognizerView.becomeFirstResponder()
        {
            let menuController = UIMenuController.shared
            menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
            menuController.setMenuVisible(true, animated:true)
            menuController.menuItems = [UIMenuItem(title: "Go to map", action: #selector(LocationTableViewCell.sendToMap))]
        }
    }
}

extension DrawerContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if locationData.locations.count > indexPath.row {
            let location = locationData.locations[indexPath.row]
            if let drawer = self.parent as? PulleyViewController {
                drawer.setDrawerPosition(position: .collapsed, animated: true)
                (drawer.primaryContentViewController as? MapViewController)!.centerMap(location.location.coordinate)
            }
        }
    }
}


