//
//  ProfileSkillCell.swift
//  AccountabilityPods
//
//  Created by MADRID, VASCO MADRID on 2/24/21.
//  Copyright © 2021 CapstoneGroup. All rights reserved.
//

import UIKit

class ProfileSkillCell: UITableViewCell {

    @IBOutlet weak var skillNameLabel: UILabel!
    @IBOutlet weak var skillDescLabel: UILabel!
    
    func setSkill(skill: Skill)
    {
        self.skillNameLabel.text = skill.name
        self.skillDescLabel.text = skill.desc
    }
}
