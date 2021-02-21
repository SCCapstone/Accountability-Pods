//
//  ProfileCell.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/20/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    func setProfile(profile: Profile) {
        self.nameLabel.text = profile.firstName + " " + profile.lastName
        self.usernameLabel.text = "@" + profile.userName
    }
    
}
