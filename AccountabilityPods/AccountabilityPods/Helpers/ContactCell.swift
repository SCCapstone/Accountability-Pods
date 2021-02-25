//
//  ContactCell.swift
//  AccountabilityPods
//
//  Created by KAHAN-THOMAS, JHADA L on 2/25/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    
    @IBOutlet weak var nameL: UILabel!
    
    
    @IBOutlet weak var usernameL: UILabel!
    
    
    func setContact(profile: Profile) {
        self.nameL.text = profile.firstName + " " + profile.lastName
        self.usernameL.text = "@" + profile.uid
    }
    
}
