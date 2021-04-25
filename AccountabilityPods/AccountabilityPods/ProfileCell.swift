//
//  ProfileCell.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/20/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
//  Description: Class for a cell in any table that has profiles (contacts, search)
import UIKit

class ProfileCell: UITableViewCell {
    /// The name of the user whose profile is in cell
    @IBOutlet weak var nameLabel: UILabel!
    /// The username of the user whose profile is in the cell
    @IBOutlet weak var usernameLabel: UILabel!
    
    /// Sets the text in the cell from data in a given profile obejct
    ///
    /// - Parameter profile: the profile object displayed in the cell (passed from table controller)
    func setProfile(profile: Profile) {
        self.nameLabel.text = profile.firstName + " " + profile.lastName
        self.usernameLabel.text = "@" + profile.uid
    }
    
}
