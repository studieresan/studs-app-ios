//
//  LocationTableViewCell.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-06-10.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import Foundation
import UIKit

class LocationTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var statusImage: UIImageView!

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
}
