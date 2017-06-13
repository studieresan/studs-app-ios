//
//  SecondViewController.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-05-30.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import UIKit
import Firebase
import Pulley
import CoreLocation

class TipViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var locationData = LocationData.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 180
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTips(_ number: Int) -> [TipLocation] {
        switch number {
        case 0:
            return locationData.newYorkTips
        case 1:
            return locationData.vancouverTips
        case 2:
            return locationData.portlandTips
        case 3:
            return locationData.sanFranciscoTips
        default:
            return [] as! [TipLocation]
        }
    }
}

extension TipViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTips(section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TipTableViewCell", for: indexPath) as! TipTableViewCell
        
        let location = getTips(indexPath.section)[indexPath.row]
        
        cell.nameLabel?.text = location.name
        cell.addressLabel?.text = location.address
        
        cell.descriptionTextVIew?.isHidden = false
        cell.descriptionTextVIew?.text = location.description
        cell.descriptionTextVIew?.textContainerInset = UIEdgeInsets.zero
        cell.descriptionTextVIew?.textContainer.lineFragmentPadding = 0
        cell.descriptionTextVIew?.layoutManager.ensureLayout(for: cell.descriptionTextVIew.textContainer)
        
        switch location.category {
        case "drink":
            cell.categoryImage.image = UIImage(named: "bar")
        case "eat":
            cell.categoryImage.image = UIImage(named: "dining-room")
        case "shopping":
            cell.categoryImage.image = UIImage(named: "shopping-bag")
        case "activity":
            cell.categoryImage.image = UIImage(named: "ferris-wheel")
        default:
            break;
        }
        
        switch location.daynight {
            case "both":
                cell.daynightImage.image = UIImage(named: "24hour")
            case "day":
                cell.daynightImage.image = UIImage(named: "sun")
            case "night":
                cell.daynightImage.image = UIImage(named: "moon")
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,  titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "New York"
        case 1:
            return "Vancouver"
        case 2:
            return "Portland"
        case 3:
            return "San Francisco"
        default:
            return ""
        }
    }
}

extension TipViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let location = getTips(indexPath.section)[indexPath.row]
        
        if location.longitude != nil {
            let tabBarController = self.parent as! UITabBarController
            tabBarController.selectedIndex = 0
            let viewController = tabBarController.viewControllers?[0] as? PulleyViewController
            (viewController!.primaryContentViewController as? MapViewController)!.centerMap(CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!))
        }
    }
    
    func tableView (_ tableView: UITableView , heightForHeaderInSection section:Int) -> CGFloat {
        return 20.0
    }
}


