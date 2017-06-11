//
//  LocationTableViewCell.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-06-10.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var statusImage: UIImageView!

    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatarView.layer.cornerRadius = 30
        avatarView.layer.masksToBounds = true;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(LocationTableViewCell.sendToMap) {
            return true
        }
        
        return false
    }
    
    internal func sendToMap(sender: AnyObject?) {
        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationLabel?.text
        mapItem.openInMaps(launchOptions: options)
    }
}
