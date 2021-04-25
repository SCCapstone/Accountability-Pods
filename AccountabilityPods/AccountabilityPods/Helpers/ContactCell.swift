//
//  ContactCell.swift
//  AccountabilityPods
//
//  Created by KAHAN-THOMAS, JHADA L on 2/25/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//
//  Description: Class for a cell in messaging table

import UIKit

class ContactCell: UITableViewCell {
    
    /// The name of contact
    @IBOutlet weak var nameL: UILabel!
    /// The username of the contact
    @IBOutlet weak var usernameL: UILabel!
    
    /// Sets the text in the cell from data in a given profile obejct
    ///
    /// - Parameter profile: the profile object displayed in the cell (passed from table controller)
    func setContact(profile: Profile) {
        self.nameL.text = profile.firstName + " " + profile.lastName
        self.usernameL.text = "@" + profile.uid
    }
    
}
